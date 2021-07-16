pragma solidity >=0.6.0 <8.0.0;
pragma experimental ABIEncoderV2;

import "@lazyledger/protobuf3-solidity-lib/contracts/ProtobufLib.sol";

library IpfsFunctions {
   bytes2 constant sha256_32b = 0x1220;
   enum DataType {
        Raw ,
        Directory ,
        File,
        Metadata ,
        Symlink,
        HAMTShard
    }
    
    function file_content_in_folder(
        bytes32[] memory hashes_, string[] memory names_, uint64[] memory sizes_,
        uint insertAt, bytes memory file_content, string memory filename
    ) public pure returns (bytes32) {
        bytes32[] memory hashes = new bytes32[](hashes_.length + 1);
        string[] memory names = new string[](hashes_.length + 1);
        uint64[] memory sizes = new uint64[](hashes_.length + 1);
        (bytes32 h, uint s) = calculate_ipfs_sha256_32_single_chunk(file_content);

        for (uint i=0; i < hashes_.length; i++) {
            uint loc = i;
            if(i >= insertAt){loc=i+1;}
            hashes[loc] = hashes_[i];
            names[loc] = names_[i];
            sizes[loc] = sizes_[i];
        }
        hashes[insertAt] = h;
        names[insertAt] = filename;
        sizes[insertAt] = uint64(s);
        
        return calculate_folder_hash(hashes, names, sizes);
    }
    
    function calculate_ipfs_sha256_32_single_chunk(bytes memory file_content) public pure returns (bytes32, uint) {
        require(file_content.length <= 65536, "Max content size is 65536 bytes");
        bytes memory data_msg = ProtobufLib.encode_key(1, uint64(ProtobufLib.WireType.Varint));
        data_msg = abi.encodePacked(data_msg,  ProtobufLib.encode_varint(uint64(DataType.File)));
        data_msg = abi.encodePacked(data_msg,  ProtobufLib.encode_key(2, uint64(ProtobufLib.WireType.LengthDelimited)));
        data_msg = abi.encodePacked(data_msg,  ProtobufLib.encode_bytes(file_content));
        data_msg = abi.encodePacked(data_msg,  ProtobufLib.encode_key(3, uint64(ProtobufLib.WireType.Varint)));
        data_msg = abi.encodePacked(data_msg,  ProtobufLib.encode_varint(uint64(file_content.length)));       

        bytes memory PBNode = ProtobufLib.encode_key(1, uint64(ProtobufLib.WireType.LengthDelimited));
        PBNode = abi.encodePacked(PBNode,  ProtobufLib.encode_bytes(data_msg));
        return (sha256(PBNode), PBNode.length);
    }

    function pack_hash(bytes32 h) public pure returns (bytes memory) {
        return abi.encodePacked(sha256_32b, h);
    }

    function calculate_folder_hash(bytes32[] memory hashes, string[] memory names, uint64[] memory sizes) public pure returns (bytes32) {
        require(hashes.length  == names.length && hashes.length == sizes.length, "All arrays must be of the same size");
        
        bytes memory node_msg;
      
      
        for (uint i=0; i<hashes.length; i++) {
            
            bytes memory embedded;
            
            embedded = abi.encodePacked(embedded,  ProtobufLib.encode_key(1, uint64(ProtobufLib.WireType.LengthDelimited)));
            embedded = abi.encodePacked(embedded,  ProtobufLib.encode_bytes(abi.encodePacked(sha256_32b, hashes[i])));
            embedded = abi.encodePacked(embedded,  ProtobufLib.encode_key(2, uint64(ProtobufLib.WireType.LengthDelimited)));
            embedded = abi.encodePacked(embedded,  ProtobufLib.encode_string(names[i]));
            embedded = abi.encodePacked(embedded,  ProtobufLib.encode_key(3, uint64(ProtobufLib.WireType.Varint)));
            embedded = abi.encodePacked(embedded,  ProtobufLib.encode_uint64(sizes[i]));

            node_msg = abi.encodePacked(node_msg,  ProtobufLib.encode_key(2, uint64(ProtobufLib.WireType.LengthDelimited)));
            node_msg = abi.encodePacked(node_msg,  ProtobufLib.encode_bytes(embedded));
           
         
        }
        bytes memory data_msg = ProtobufLib.encode_key(1, uint64(ProtobufLib.WireType.Varint));
        data_msg = abi.encodePacked(data_msg,  ProtobufLib.encode_varint(uint64(DataType.Directory)));


        node_msg = abi.encodePacked(node_msg,  ProtobufLib.encode_key(1, uint64(ProtobufLib.WireType.LengthDelimited)));
        node_msg = abi.encodePacked(node_msg,  ProtobufLib.encode_bytes(data_msg));
      
        
        return sha256(node_msg);
    }
}

/*

    // An IPFS MerkleDAG Link
message PBLink {

    // multihash of the target object
    optional bytes Hash = 1;
  
    // utf string name. should be unique per object
    optional string Name = 2;
  
    // cumulative size of target object
    optional uint64 Tsize = 3;
  }
  
  // An IPFS MerkleDAG Node
  message PBNode {
  
    // refs to other objects
    repeated PBLink Links = 2;
  
    // opaque user data
    optional bytes Data = 1;
  }


  message Data {
    enum DataType {
        Raw = 0;
        Directory = 1;
        File = 2;
        Metadata = 3;
        Symlink = 4;
        HAMTShard = 5;
    }

    required DataType Type = 1;
    optional bytes Data = 2;
    optional uint64 filesize = 3;
    repeated uint64 blocksizes = 4;

    optional uint64 hashType = 5;
    optional uint64 fanout = 6;
}

message Metadata {
    optional string MimeType = 1;
}


} */