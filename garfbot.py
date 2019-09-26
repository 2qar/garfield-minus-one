import sys
from subprocess import run, PIPE
from datetime import date
from tweepy import OAuthHandler, API
from json import load

try:
    today = sys.argv[1]
except IndexError:
    today = date.today().strftime("%Y-%m-%d")
garf_filename = run(['./get_comic.sh', today], stdout=PIPE).stdout.decode('utf-8').replace('\n', '')
if garf_filename.endswith('.png'):
    print("Posting comic for today, ", today)
    with open('tokens.json') as file:
        tokens = load(file)

    auth = OAuthHandler(tokens['consumer_key'], tokens['consumer_key_secret'])
    auth.set_access_token(tokens['access_token'], tokens['access_token_secret'])

    api = API(auth)
    api.update_with_media(garf_filename, status="garfield without the third panel")
    run(['rm', garf_filename])
else:
    print(garf_filename)
