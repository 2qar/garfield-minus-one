from subprocess import run, PIPE
from tweepy import OAuthHandler, API
from json import load

garf_filename = run('./get_comic.sh', stdout=PIPE).stdout.decode('utf-8').replace('\n', '')
if garf_filename.endswith('.png'):
    with open('tokens.json') as file:
        tokens = load(file)

    auth = OAuthHandler(tokens['consumer_key'], tokens['consumer_key_secret'])
    auth.set_access_token(tokens['access_token'], tokens['access_token_secret'])

    api = API(auth)
    api.update_with_media(garf_filename)
    run(['rm', garf_filename])
