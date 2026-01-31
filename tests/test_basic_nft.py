
import boa

def test_basic_nft_deploys():
    nft = boa.load("src/basic_nft.vy")
    assert nft.name() == "Puppy NFT"
    assert nft.symbol() == "PNFT"
    

def test_mint_creates_token():
    nft = boa.load("src/basic_nft.vy")
    nft.mint("QmTestURI")

    assert nft.totalSupply() == 1
    assert nft.ownerOf(0) == boa.env.eoa

def test_token_uri_is_correct():
    nft = boa.load("src/basic_nft.vy")
    uri = "QmTestURI"
    nft.mint(uri)

    returned_uri = nft.tokenURI(0)
    assert uri in returned_uri


