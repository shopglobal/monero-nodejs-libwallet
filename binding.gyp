{
  "conditions": [
    ['OS=="linux"', {
      "variables": {
        'additional_libraries': [
          "-lboost_serialization", 
          "-lboost_thread", 
          "-lboost_system", 
          "-lboost_date_time", 
          "-lboost_filesystem", 
          "-lboost_chrono", 
          "-lboost_program_options", 
          "-lboost_regex",
          "-lpcsclite",
        ]
      }
    }],
    ['OS=="mac"', {
      "variables": {
        'additional_libraries': [
          "-lboost_serialization-mt", 
          "-lboost_thread-mt", 
          "-lboost_system-mt", 
          "-lboost_date_time-mt", 
          "-lboost_filesystem-mt", 
          "-lboost_chrono-mt", 
          "-lboost_program_options-mt", 
          "-lboost_regex-mt",
          "-framework PCSC",
        ]
      }
    }]
  ],
  "targets": [
    {
      "target_name": "build_monero",
      "type": "none",
      "actions": [
        {
          "action_name": "retrieve_from_github",
          "inputs": "",
          "outputs": [
            "../deps/libwallet_merged.a", 
            "../deps/libepee.a", 
            "../deps/libeasylogging.a", 
            "../deps/liblmdb.a", 
            "../deps/libunbound.a", 
          ],
          "action": ["./build.sh"],
          "message": "Building monero libraries",
        },
      ],
    },
    {
      "target_name": "monero",
      "dependencies": ["build_monero"],
      "sources": [
        "src/addon.cc",   
        "src/wallet.cc", 
        "src/walletcallbacks.cc",
        "src/walletargs.cc",
        "src/deferredtask.cc",
        "src/wallettasks.cc",
        "src/pendingtransaction.cc",],
      "libraries": [
            "../deps/libwallet_merged.a", 
			      "../deps/libepee.a", 
			      "../deps/libeasylogging.a", 
			      "../deps/liblmdb.a", 
			      "../deps/libunbound.a", 
            "<@(additional_libraries)",
			      "-lssl",
            "-lcrypto",
            "-lz",
            ""],
      "include_dirs": [
           "include"
      ]
    },
    {
      "target_name": "action_after_build",
      "type": "none",
      "dependencies": [ "<(module_name)" ],
      "copies": [
        {
          "files": [ "<(PRODUCT_DIR)/<(module_name).node" ],
          "destination": "<(module_path)"
        }
      ]
    }
  ]
}