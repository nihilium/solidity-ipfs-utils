# IPFS Utils

Simple smart contract library for IPFS hashing utils to be used on-chain.

### Status

Currently in development as needed by the Nihilium project, will expand further when needed.

## Install

```
npm install @nihilium/solidity-ipfs-utils
```

```
import '@nihilium/solidity-ipfs-utils/contracts/IpfsFunctions.sol'
```



```
bytes32 ipfshash = IpfsFunctions.calculate_ipfs_sha256_32_single_chunk(content);
```

See tests for further usuage in javascript.
