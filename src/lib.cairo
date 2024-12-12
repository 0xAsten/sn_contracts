use starknet::{ContractAddress};

#[starknet::interface]
pub trait ITestStarknet<TContractState> {
    fn increase_balance(ref self: TContractState, address: ContractAddress, amount: u256);

    fn get_balance(self: @TContractState, address: ContractAddress) -> u256;
}

#[starknet::contract]
mod TestStarknet {
    use core::starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map
    };
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        user_values: Map<ContractAddress, u256>,
    }

    #[abi(embed_v0)]
    impl TestStarknetImpl of super::ITestStarknet<ContractState> {
        fn increase_balance(ref self: ContractState, address: ContractAddress, amount: u256) {
            assert(amount != 0, 'Amount cannot be 0');
            self.user_values.entry(address).write(self.user_values.entry(address).read() + amount);
        }

        fn get_balance(self: @ContractState, address: ContractAddress) -> u256 {
            self.user_values.entry(address).read()
        }
    }
}

