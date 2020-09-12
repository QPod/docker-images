import os, sys, json, requests

def generate(image, tags=None):
    if tags is None:
        try:
            url_api_tags = 'https://registry.hub.docker.com/v1/repositories/%s/tags' % image
            tags = requests.get(url_api_tags).json()
            tags = list(t['name'] for t in tags)
        except:
            tags = ['latest']
        
    tags = ','.join(tags)

    destinations = ['docker.pkg.github.com']

    config = {
        "auth": {},
        "images": {}
    }
    
    crend_uname = os.environ.get('DOCKER_REGISTRY_USERNAME', None)
    crend_paswd = os.environ.get('DOCKER_REGISTRY_PASSWORD', None)

    for dest in destinations:
        config['auth'][dest] = {
            "username": crend_uname,
            "password": crend_paswd,
            "insecure": True
        }
        
        config['images']["qpod/%s:%s" % (image, tags)] = "%s/qpod/docker-images/%s" % (dest, image)

    return config


if __name__ == '__main__':
    args = sys.argv[1:]
    img = args[0]
    tags = args[1:] or None
    data = generate(image=img, tags=tags)
    with open('./config.json', 'wt') as fp:
        json.dump(data, fp, ensure_ascii=False, indent=2, sort_keys=True)
