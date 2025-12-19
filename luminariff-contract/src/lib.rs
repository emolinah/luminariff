#![no_std]

use soroban_sdk::{
    contract, contractimpl, contracttype, token, Address, Env, String, Vec, symbol_short,
};

// Constantes del contrato
const TICKET_PRICE: i128 = 1_0000000; // 1 USDC (7 decimales)
const ADMIN_KEY: &str = "ADMIN";
const PARTICIPANTS_KEY: &str = "PARTICIPANTS";

/// Estructura para almacenar información de cada participante
#[contracttype]
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Participant {
    pub stellar_address: Address,
    pub roblox_user_id: String,
}

/// Enum para manejar las claves de almacenamiento del contrato
#[contracttype]
#[derive(Clone)]
pub enum DataKey {
    Admin,
    Participants,
    TokenAddress,
}

#[contract]
pub struct LuminariffContract;

#[contractimpl]
impl LuminariffContract {
    /// Inicializa el contrato estableciendo el administrador y el token USDC
    ///
    /// # Argumentos
    /// * `env` - El entorno de ejecución de Soroban
    /// * `admin` - La dirección del administrador que podrá ejecutar el sorteo
    /// * `token_address` - La dirección del contrato del token USDC
    pub fn initialize(env: Env, admin: Address, token_address: Address) {
        // Verificar que el contrato no haya sido inicializado antes
        if env.storage().instance().has(&DataKey::Admin) {
            panic!("Contract already initialized");
        }

        // Guardar el administrador
        env.storage().instance().set(&DataKey::Admin, &admin);

        // Guardar la dirección del token USDC
        env.storage().instance().set(&DataKey::TokenAddress, &token_address);

        // Inicializar la lista de participantes vacía
        let participants: Vec<Participant> = Vec::new(&env);
        env.storage().instance().set(&DataKey::Participants, &participants);
    }

    /// Permite a un usuario comprar un ticket enviando 1 USDC al contrato
    ///
    /// # Argumentos
    /// * `env` - El entorno de ejecución de Soroban
    /// * `buyer` - La dirección del comprador que debe autorizar la transacción
    /// * `roblox_user_id` - El ID del usuario de Roblox como String
    ///
    /// # Funcionamiento
    /// 1. Verifica que el usuario autorice la transacción
    /// 2. Transfiere 1 USDC del usuario al contrato
    /// 3. Registra al participante en la lista
    pub fn buy_ticket(env: Env, buyer: Address, roblox_user_id: String) {
        // Requerir autenticación del comprador
        buyer.require_auth();

        // Obtener la dirección del token USDC
        let token_address: Address = env
            .storage()
            .instance()
            .get(&DataKey::TokenAddress)
            .expect("Token address not set");

        // Crear cliente del token
        let token_client = token::Client::new(&env, &token_address);

        // Obtener la dirección del contrato para recibir los tokens
        let contract_address = env.current_contract_address();

        // Transferir 1 USDC del comprador al contrato
        token_client.transfer(&buyer, &contract_address, &TICKET_PRICE);

        // Crear estructura de participante
        let participant = Participant {
            stellar_address: buyer.clone(),
            roblox_user_id: roblox_user_id.clone(),
        };

        // Obtener lista actual de participantes
        let mut participants: Vec<Participant> = env
            .storage()
            .instance()
            .get(&DataKey::Participants)
            .unwrap_or(Vec::new(&env));

        // Agregar nuevo participante
        participants.push_back(participant);

        // Guardar lista actualizada
        env.storage().instance().set(&DataKey::Participants, &participants);

        // Emitir evento de compra de ticket
        env.events().publish(
            (symbol_short!("ticket"), buyer),
            roblox_user_id,
        );
    }

    /// Devuelve la lista completa de participantes (solo lectura)
    ///
    /// # Retorna
    /// Un vector con todos los participantes registrados
    pub fn get_players(env: Env) -> Vec<Participant> {
        env.storage()
            .instance()
            .get(&DataKey::Participants)
            .unwrap_or(Vec::new(&env))
    }

    /// Devuelve solo los IDs de Roblox de todos los participantes
    /// Útil para mostrar en el frontend
    ///
    /// # Retorna
    /// Un vector con todos los IDs de Roblox registrados
    pub fn get_roblox_ids(env: Env) -> Vec<String> {
        let participants: Vec<Participant> = Self::get_players(env.clone());
        let mut roblox_ids = Vec::new(&env);

        for i in 0..participants.len() {
            if let Some(participant) = participants.get(i) {
                roblox_ids.push_back(participant.roblox_user_id);
            }
        }

        roblox_ids
    }

    /// Ejecuta el sorteo y selecciona un ganador al azar
    /// Solo puede ser ejecutado por el administrador
    ///
    /// # Argumentos
    /// * `env` - El entorno de ejecución de Soroban
    /// * `admin` - La dirección del administrador (debe coincidir con la guardada)
    ///
    /// # Retorna
    /// El Participant ganador seleccionado aleatoriamente
    ///
    /// # Algoritmo de aleatoriedad
    /// Usa el timestamp del ledger y el hash de la secuencia como semilla
    /// para generar un número pseudo-aleatorio
    pub fn execute_draw(env: Env, admin: Address) -> Participant {
        // Verificar que quien llama es el administrador
        admin.require_auth();

        let stored_admin: Address = env
            .storage()
            .instance()
            .get(&DataKey::Admin)
            .expect("Admin not set");

        if admin != stored_admin {
            panic!("Only admin can execute draw");
        }

        // Obtener lista de participantes
        let participants: Vec<Participant> = env
            .storage()
            .instance()
            .get(&DataKey::Participants)
            .expect("No participants found");

        let participants_count = participants.len();

        if participants_count == 0 {
            panic!("No participants to draw from");
        }

        // Generar número pseudo-aleatorio usando el timestamp del ledger
        // y la secuencia del ledger como semillas
        let timestamp = env.ledger().timestamp();
        let sequence = env.ledger().sequence();

        // Combinar timestamp y sequence para mayor entropía
        let seed = timestamp.wrapping_mul(sequence as u64);

        // Calcular índice del ganador
        let winner_index = (seed as u32) % participants_count;

        // Obtener el ganador
        let winner = participants
            .get(winner_index)
            .expect("Failed to get winner");

        // Emitir evento con el ganador
        env.events().publish(
            (symbol_short!("winner"),),
            winner.clone(),
        );

        // Limpiar la lista de participantes para la próxima rifa
        let empty_participants: Vec<Participant> = Vec::new(&env);
        env.storage().instance().set(&DataKey::Participants, &empty_participants);

        winner
    }

    /// Obtiene el número total de participantes
    ///
    /// # Retorna
    /// El número de tickets vendidos
    pub fn get_participants_count(env: Env) -> u32 {
        let participants: Vec<Participant> = env
            .storage()
            .instance()
            .get(&DataKey::Participants)
            .unwrap_or(Vec::new(&env));

        participants.len()
    }

    /// Permite al administrador retirar los fondos del contrato
    ///
    /// # Argumentos
    /// * `env` - El entorno de ejecución
    /// * `admin` - La dirección del administrador
    /// * `amount` - La cantidad a retirar
    pub fn withdraw_funds(env: Env, admin: Address, amount: i128) {
        // Verificar que quien llama es el administrador
        admin.require_auth();

        let stored_admin: Address = env
            .storage()
            .instance()
            .get(&DataKey::Admin)
            .expect("Admin not set");

        if admin != stored_admin {
            panic!("Only admin can withdraw funds");
        }

        // Obtener la dirección del token
        let token_address: Address = env
            .storage()
            .instance()
            .get(&DataKey::TokenAddress)
            .expect("Token address not set");

        let token_client = token::Client::new(&env, &token_address);
        let contract_address = env.current_contract_address();

        // Transferir fondos al administrador
        token_client.transfer(&contract_address, &admin, &amount);

        // Emitir evento de retiro
        env.events().publish(
            (symbol_short!("withdraw"), admin),
            amount,
        );
    }

    /// Obtiene la dirección del administrador
    pub fn get_admin(env: Env) -> Address {
        env.storage()
            .instance()
            .get(&DataKey::Admin)
            .expect("Admin not set")
    }
}

#[cfg(test)]
mod test {
    use super::*;
    use soroban_sdk::{testutils::Address as _, Env};

    #[test]
    fn test_initialize() {
        let env = Env::default();
        let contract_id = env.register_contract(None, LuminariffContract);
        let client = LuminariffContractClient::new(&env, &contract_id);

        let admin = Address::generate(&env);
        let token_address = Address::generate(&env);

        client.initialize(&admin, &token_address);

        assert_eq!(client.get_participants_count(), 0);
    }

    #[test]
    fn test_get_players_empty() {
        let env = Env::default();
        let contract_id = env.register_contract(None, LuminariffContract);
        let client = LuminariffContractClient::new(&env, &contract_id);

        let admin = Address::generate(&env);
        let token_address = Address::generate(&env);

        client.initialize(&admin, &token_address);

        let players = client.get_players();
        assert_eq!(players.len(), 0);
    }
}
