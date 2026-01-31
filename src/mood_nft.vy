# pragma version ^0.4.0

"""
@license MIT
@title Mood NFT
"""

from snekmate.tokens import erc721
from snekmate.auth import ownable as ow
from snekmate.utils import base64

initializes: ow
initializes: erc721[ownable := ow]
flag Mood:
    HAPPY
    SAD

# ------------------------------------------------------------------
#                          STATE VARIABLE
# ------------------------------------------------------------------

NAME: constant(String[25]) = "Mood NFT"
SYMBOL: constant(String[5]) = "MNFT"
BASE_URI: public(constant(String[34])) = ""
EIP_712_VERSION: constant(String[1]) = "1"

HAPPY_SVG_URI: immutable(String[800])
SAD_SVG_URI: immutable(String[800])
FINAL_STRING_SIZE: constant(uint256) = (4* base64._DATA_OUTPUT_BOUND)+80
JSON_BASE_URI: constant(String[29]) = "data:application/json;base64,"
IMG_BASE_URI_SIZE: constant(uint256) = 26
JSON_BASE_URI_SIZE: constant(uint256) = 29
IMG_BASE_URI: constant(String[IMG_BASE_URI_SIZE]) = "data:image/svg+xml;base64,"

exports: (
    erc721.owner,
    erc721.balanceOf,
    erc721.ownerOf,
    erc721.getApproved,
    erc721.approve,
    erc721.setApprovalForAll,
    erc721.transferFrom,
    erc721.safeTransferFrom,
    # erc721.tokenURI, 
    erc721.totalSupply,
    erc721.tokenByIndex,
    erc721.tokenOfOwnerByIndex,
    erc721.burn,
    # erc721.safe_mint, 
    # erc721.set_minter,
    erc721.permit,
    erc721.DOMAIN_SEPARATOR,
    erc721.transfer_ownership,
    erc721.renounce_ownership,
    erc721.name,
    erc721.symbol,
    erc721.isApprovedForAll,
    erc721.is_minter,
    erc721.nonces,
)

#Storage 
token_id_to_mood: public(HashMap[uint256, Mood])

@deploy
def __init__(happy_svg_uri: String[800],sad_svg_uri: String[800]):
    ow.__init__()
    erc721.__init__(NAME, SYMBOL, BASE_URI, NAME, EIP_712_VERSION)
    HAPPY_SVG_URI = happy_svg_uri
    SAD_SVG_URI = sad_svg_uri

@external
def mint_nft():
    token_id: uint256 = erc721._counter
    erc721._counter = token_id + 1
    self.token_id_to_mood[token_id] = Mood.HAPPY
    erc721._safe_mint(msg.sender, token_id, b"")
    


@external
def flip_mood(token_id: uint256):
    assert erc721._is_approved_or_owner(msg.sender, token_id)
    if self.token_id_to_mood[token_id] == Mood.HAPPY:
        self.token_id_to_mood[token_id] = Mood.SAD
    else:
        self.token_id_to_mood[token_id] = Mood.HAPPY
    


@external
@view    
def tokenURI(token_id: uint256) -> String[FINAL_STRING_SIZE]:
    assert erc721._exists(token_id), "Nonexistent token"

    image_uri: String[800] = HAPPY_SVG_URI

    if self.token_id_to_mood[token_id] == Mood.SAD:
        image_uri = SAD_SVG_URI

    # Construct the JSON metadata
    json_string: String[1024] = concat(
        '{"name":"',
        NAME,
        '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
        '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
        image_uri,
        '"}',
    )
    json_bytes: Bytes[1024] = convert(json_string, Bytes[1024])

    # [[0x02322],[0x2952]]

    encoded_chunks: DynArray[
        String[4], base64._DATA_OUTPUT_BOUND
    ] = base64._encode(json_bytes, True)

    result: String[FINAL_STRING_SIZE] = JSON_BASE_URI

    counter: uint256 = JSON_BASE_URI_SIZE
    for encoded_chunk: String[4] in encoded_chunks:
        result = self.set_indice_truncated(result, counter, encoded_chunk)
        counter += 4
    return result
    

@external
@pure
def svg_to_uri(svg: String[1024]) -> String[FINAL_STRING_SIZE]:
    svg_bytes: Bytes[1024] = convert(svg, Bytes[1024])
    encoded_chunks: DynArray[
        String[4], base64._DATA_OUTPUT_BOUND
    ] = base64._encode(svg_bytes, True)
    result: String[FINAL_STRING_SIZE] = JSON_BASE_URI

    counter: uint256 = IMG_BASE_URI_SIZE
    for encoded_chunk: String[4] in encoded_chunks:
        result = self.set_indice_truncated(result, counter, encoded_chunk)
        counter += 4
    return result


# ------------------------------------------------------------------
#                       INTERNAL FUNCTIONS
# ------------------------------------------------------------------
@internal
@pure
def set_indice_truncated(
    result: String[FINAL_STRING_SIZE], index: uint256, chunk_to_set: String[4]
) -> String[FINAL_STRING_SIZE]:
    """
    We set the index of a string, while truncating all values after the index
    """
    buffer: String[FINAL_STRING_SIZE * 2] = concat(
        slice(result, 0, index), chunk_to_set
    )
    return abi_decode(abi_encode(buffer), (String[FINAL_STRING_SIZE]))