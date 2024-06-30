#[starknet::contract]
mod nft_contracts {

    use core::option::OptionTrait;
    use core::traits::TryInto;
    use starknet:: {
        ContractAddress, get_caller_address
    };
    
    
    const NAME: felt252 = 0x4d792044656d6f204e4654;

    // your  NFT token symbols as byte , eg: "GRT" -> 0x475254
    const SYMBOL: felt252 = 0x475254;

    const BASE_URI_PART_1: felt252 = 0x697066733a2f2f516d505a6e336f5967486f676343643835;
    const BASE_URI_PART_2: felt252 = 0x697251685033794d61446139387878683654653550426e53;
    const BASE_URI_PART_3: felt252 = 0x61626859722f;

    // Total number of NFTs that can be minted
    const MAX_SUPPLY: u256 = 100;
    const ADMIN_ADDRESS: felt252 = 0x001356F388A5E37015FEA32329aCF6cEa266139FA745A1123d37ab8A92c025A5;

    const VERSION_CODE: u256 = 202311150001001; /// YYYYMMDD000NONCE
    //# Const Default Init End #
    
    // ERC 165 interface codes
    const INTERFACE_ERC165: felt252 = 0x01ffc9a7;
    const INTERFACE_ERC721: felt252 = 0x80ac58cd;
    const INTERFACE_ERC721_METADATA: felt252 = 0x5b5e139f;
    const INTERFACE_ERC721_RECEIVER: felt252 = 0x150b7a02;

    // storage variable
    #[storage]
    struct Storage {
        owners: StorageMap<u256, ContractAddress>,
        balances: StorageMap<ContractAddress, u256>,
        token_approvals: StorageMap<u256, ContractAddress>,
        operator_approvals: StorageMap<(ContractAddress, ContractAddress), bool>,
        count: StorageValue<u256>,
        
        // Collection storage
        collections: StorageMap<u256, Collection>,
        collection_count: StorageValue<u256>,

        //NFT Storage
        nfts: StorageMap<u256, NFT>,
        nft_count: StorageValue<u256>,
    }
    // Define a struct for Collection
    #[derive(Default, Clone, Copy)]
    struct Collection {
        creator: ContractAddress,
        name: felt252,
        symbol: felt252,
        base_uri_part1: felt252,
        base_uri_part2: felt252,
        base_uri_part3: felt252,
        max_supply: u256,
    }
    struct NFT {
        owner: ContractAddress,
        collection_id: u256,
        token_id: u256,
    }
    //EVENT
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Approval: Approval,
        Transfer: Transfer,
        ApprovalForAll: ApprovalForAll,
        CollectionCreated: CollectionCreated,
        NFTMinted: NFTMinted
    }

    // Approval event emitted on token approval
    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner:ContractAddress ,
        to: ContractAddress,
        token_id: u256,
    }
    // Transfer event emitted on token transfer
    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress ,
        to: ContractAddress,
        token_id: u256,
    }
    // ApprovalForAll event emitted on approval for operators
    #[derive(Drop, starknet::Event)]
    struct ApprovalForAll {
        owner: ContractAddress ,
        operator: ContractAddress,
        approved: bool,
    }
    // CollectionCreated event emmitted on create collection
    #[derive(Drop, starknet::Event)]
    struct CollectionCreated {
        creator: ContractAddress ,
        collection_id: u256,
        name: felt252,
        symbol: felt252
    }
    #[derive(Drop, starknet::Event)]
    struct NFTMinted  {
        owner: ContractAddress,
        collection_id: u256,
        token_id: u256,
    }
    // Constructor - initialized on deployent
    // this funtion will be called only when deploying the contract

    #[constructor]
    fn constructor(ref self: ContractState) {
        self.initConfig();
    }
    
    #[generate_trait]
    impl ConfigImpl of ConfigTrait {
        fn initConfig(ref self:ContractState,storage:@Storage){
            //Configure the contract based on parameters when deploying the contract if needed
            Storage {
                owners: StorageMap::new(),
                balances: StorageMap::new(),
                token_approvals: StorageMap::new(),
                operator_approvals: StorageMap::new(),
                count: StorageValue::new(0),
                collections: StorageMap::new(),
                collection_count: StorageValue::new(0),
                nfts: StorageMap::new(),
                nft_count: StorageValue::new(0),
            }
        }
    }
    
    #[generate_trait]
    impl nftHelperImpl of nftHelperTrait {
        fn create_collection (
            self:ContractState,
            name: felt252,
            symbol: felt252,
            base_uri_part1: felt252,
            base_uri_part2: felt252,
            base_uri_part3: felt252,
            max_supply: u256,

        ){
            // Ensure caller is authorized to create collections (you can add checks as needed)
            let caller = get_caller_address();
            assert!(caller == ADMIN_ADDRESS, "Only admin can create collections.");

            //Generate new collection ID
            let collection_id = self.collection_count.get();
            self.collection_count.set(collection_id + 1);

            // Create new collection object
            let new_collection = Collection {
                creator: caller,
                name,
                symbol,
                base_uri_part1,
                base_uri_part2,
                base_uri_part3,
                max_supply,
            };
            // Store the new collection in contract storage
            storage.collections.insert(collection_id, new_collection);
            
            // Emit CollectionCreated event
            Event::CollectionCreated(CollectionCreated {
                creator: caller,
                collection_id,
                name,
                symbol,
            });
        }
        #[test]
    fn test_create_collection() {
        // Test create_collection function
        
        
    }
    }
}


    
