import {expect, use} from 'chai';
import {Contract, ethers} from 'ethers';
import {deployContract, MockProvider, solidity, link} from 'ethereum-waffle';

import IPFSContract from '../build/IpfsFunctions.json';


use(solidity);



describe('IpfsTest', () => {
    const [wallet, walletTo] = new MockProvider().getWallets();
    let sc: Contract;
    
    beforeEach(async () => {
       sc = await deployContract(wallet, IPFSContract);      
    });


    it('Content in folder hashing to work', async () => {
      var folder_hashes = ["0xf782bf27d7dfa16c5556ae0e19d41a73fc380a28455abcedecd70460505f022b", 
      "0xbfccda787baba32b59c78450ac3d20b633360b43992c77289f9ed46d843561e6"]
      var names = ["altered_inputs.bytes", "anchors.bytes"]
      var sizes = [104, 6]
      var content = '0x393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393030303030303030303030303030303030303030303030303030303030303030';
      var ipfs_hash = await sc.file_content_in_folder(folder_hashes, names, sizes, 2, content, "inputs.bytes");
      
      expect((await sc.pack_hash(ipfs_hash.toString(16))).toString(16)).to.equal("0x122037340d767175bbb9a315269bf7c482993b5e0ee0173b5296413e654d9fd655dc");

    });

    
    it('Folder hashes to work', async () => {
      var folder_hashes = ["0xf782bf27d7dfa16c5556ae0e19d41a73fc380a28455abcedecd70460505f022b", 
      "0xbfccda787baba32b59c78450ac3d20b633360b43992c77289f9ed46d843561e6",
      "0xe844b8764c00d4a76ac03930a3d8f32f3df59aea3ed0ade4c3bc38a3b23a31d9"]
      var names = ["altered_inputs.bytes", "anchors.bytes", "inputs.bytes"]
      var sizes = [104, 6, 104]

      var ipfs_hash = await sc.calculate_folder_hash(folder_hashes, names, sizes);
      
      expect((await sc.pack_hash(ipfs_hash.toString(16))).toString(16)).to.equal("0x122037340d767175bbb9a315269bf7c482993b5e0ee0173b5296413e654d9fd655dc");

    });

  
    it('File hash to work', async () => {
      var ipfs_hash = await sc.calculate_ipfs_sha256_32_single_chunk('0x393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393030303030303030303030303030303030303030303030303030303030303030');
   
      expect((await sc.pack_hash(ipfs_hash[0])).toString(16)).to.equal("0x1220e844b8764c00d4a76ac03930a3d8f32f3df59aea3ed0ade4c3bc38a3b23a31d9");

      var ipfs_hash2 = await sc.calculate_ipfs_sha256_32_single_chunk('0x393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939393939383838393939393939393939393030303030303030303030303030303030303030303030303030303030303030');
      expect((await sc.pack_hash(ipfs_hash2[0])).toString(16)).to.equal("0x1220f782bf27d7dfa16c5556ae0e19d41a73fc380a28455abcedecd70460505f022b");
     
    });
  
    
  });


