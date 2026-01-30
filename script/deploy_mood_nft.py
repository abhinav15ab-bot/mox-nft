import base64
from src import mood_nft
def deploy_mood():
    happy_svg_uri =""
    sad_svg_uri = ""
    with open("./img/happy.svg","r") as f:
        happy_svg = f.read()
        happy_svg_uri = svg_to_base64_uri(happy_svg)
        print(happy_svg_uri)
    with open ("./img/sad.svg","r") as f:
        sad_svg_uri = f.read()
    
    mood_contract = mood_nft.deploy(happy_svg_uri,sad_svg_uri)

def moccasin_main():
    deploy_mood()

def svg_to_base64_uri(svg):
    svg_bytes = svg.encode("utf-8")
    base64_svg = base64.b64encode(svg_bytes).decode("utf-8")
    return f"data:image/svg+xml;base64,{base64_svg}"