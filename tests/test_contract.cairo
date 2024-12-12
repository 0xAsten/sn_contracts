use starknet::{ContractAddress, contract_address_const};

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

use sn_contracts::ITestStarknetSafeDispatcher;
use sn_contracts::ITestStarknetSafeDispatcherTrait;
use sn_contracts::ITestStarknetDispatcher;
use sn_contracts::ITestStarknetDispatcherTrait;

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

#[test]
fn test_increase_balance() {
    let contract_address = deploy_contract("TestStarknet");

    let dispatcher = ITestStarknetDispatcher { contract_address };

    let balance_before = dispatcher.get_balance(contract_address_const::<0x1>());
    assert(balance_before == 0, 'Invalid balance');

    dispatcher.increase_balance(contract_address_const::<0x1>(), 42);

    let balance_after = dispatcher.get_balance(contract_address_const::<0x1>());
    assert(balance_after == 42, 'Invalid balance');
}

#[test]
#[feature("safe_dispatcher")]
fn test_cannot_increase_balance_with_zero_value() {
    let contract_address = deploy_contract("TestStarknet");

    let safe_dispatcher = ITestStarknetSafeDispatcher { contract_address };

    let balance_before = safe_dispatcher.get_balance(contract_address_const::<0x1>()).unwrap();
    assert(balance_before == 0, 'Invalid balance');

    match safe_dispatcher.increase_balance(contract_address_const::<0x1>(), 0) {
        Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
        Result::Err(panic_data) => {
            assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
        },
    };
}

