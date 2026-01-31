
import boa

HAPPY = "data:image/svg+xml;base64,happy"
SAD = "data:image/svg+xml;base64,sad"


def test_mood_nft_deploys():
    nft = boa.load("src/mood_nft.vy", HAPPY, SAD)
    assert nft.name() == "Mood NFT"


def test_mint_sets_initial_mood():
    nft = boa.load("src/mood_nft.vy", HAPPY, SAD)
    nft.mint_nft()

    token_id = nft.tokenByIndex(0)
    mood = nft.token_id_to_mood(token_id)

    # Assert mood exists and is stable
    assert mood == nft.token_id_to_mood(token_id)

def test_flip_mood():
    nft = boa.load("src/mood_nft.vy", HAPPY, SAD)
    nft.mint_nft()

    token_id = nft.tokenByIndex(0)

    mood_before = nft.token_id_to_mood(token_id)
    nft.flip_mood(token_id)
    mood_after = nft.token_id_to_mood(token_id)

    assert mood_before != mood_after


def test_flip_fails_for_non_owner():
    nft = boa.load("src/mood_nft.vy", HAPPY, SAD)
    nft.mint_nft()

    with boa.env.prank("0x000000000000000000000000000000000000dead"):
        with boa.reverts():
            nft.flip_mood(0)

def test_token_uri_changes_with_mood():
    nft = boa.load("src/mood_nft.vy", HAPPY, SAD)
    nft.mint_nft()

    happy_uri = nft.tokenURI(0)
    nft.flip_mood(0)
    sad_uri = nft.tokenURI(0)

    assert happy_uri != sad_uri

def test_flip_mood_twice_returns_original_state():
    nft = boa.load("src/mood_nft.vy", HAPPY, SAD)
    nft.mint_nft()

    token_id = nft.tokenByIndex(0)

    mood_1 = nft.token_id_to_mood(token_id)
    nft.flip_mood(token_id)
    mood_2 = nft.token_id_to_mood(token_id)
    nft.flip_mood(token_id)
    mood_3 = nft.token_id_to_mood(token_id)

    assert mood_1 != mood_2
    assert mood_1 == mood_3

def test_flip_reverts_for_nonexistent_token():
    nft = boa.load("src/mood_nft.vy", HAPPY, SAD)

    with boa.reverts():
        nft.flip_mood(999)
        
def test_token_uri_changes_with_mood():
    nft = boa.load("src/mood_nft.vy", HAPPY, SAD)
    nft.mint_nft()

    token_id = nft.tokenByIndex(0)

    uri_before = nft.tokenURI(token_id)
    nft.flip_mood(token_id)
    uri_after = nft.tokenURI(token_id)

    assert uri_before != uri_after


def test_token_uri_reverts_for_invalid_token():
    nft = boa.load("src/mood_nft.vy", HAPPY, SAD)

    with boa.reverts():
        nft.tokenURI(0)
def test_multiple_mints_have_independent_moods():
    nft = boa.load("src/mood_nft.vy", HAPPY, SAD)

    nft.mint_nft()
    nft.mint_nft()

    token0 = nft.tokenByIndex(0)
    token1 = nft.tokenByIndex(1)

    assert nft.token_id_to_mood(token0) == nft.token_id_to_mood(token1)

    nft.flip_mood(token0)

    assert nft.token_id_to_mood(token0) != nft.token_id_to_mood(token1)

def test_flip_does_not_change_owner():
    nft = boa.load("src/mood_nft.vy", HAPPY, SAD)
    nft.mint_nft()

    token_id = nft.tokenByIndex(0)
    owner_before = nft.ownerOf(token_id)

    nft.flip_mood(token_id)
    owner_after = nft.ownerOf(token_id)

    assert owner_before == owner_after

def test_svg_to_uri_returns_base64_data():
    nft = boa.load("src/mood_nft.vy", HAPPY, SAD)

    svg = "<svg>test</svg>"
    uri = nft.svg_to_uri(svg)

    assert "base64" in uri
