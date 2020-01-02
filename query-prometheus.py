import sys
import getopt
import requests


def usage():
    print("Usage: {} <<server_url>> '<<query>>' <<time>>".format(sys.argv[0]))
    print(
"""
Example:
query-prometheus.py http://localhost:9090 'irate(http_requests_total{code="200"}[1m]) 2020-01-01T00:00:00.000Z'
"""
    )

def getArgs():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hs:q:t:", ["help", "server_url=", "query=", "time="])
        if opts:
            return opts, args
        else:
            usage()
            sys.exit(1)
    except getopt.GetoptError as err:
        # print help information and exit:
        print(err)  # will print something like "option -a not recognized"
        sys.exit(2)


def main():
    opts, args = getArgs()

    # setup envs by opt,args
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit(1)
        elif opt in ("-s", "--server_url"):
            server_url = arg
        elif opt in ("-q", "--query"):
            query = arg
        elif opt in ("-t", "--time"):
            time = arg
        else:
            usage()
            assert False, "unhandled option"

    response = requests.get('{0}/api/v1/query'.format(server_url),
        params={
            'query': '{}'.format(query),
            'time': '{}'.format(time)
        }
    )
    result = response.json()['data']['result']

    for r in result:
        print("{}".format(r['value'][1]))


if __name__ == "__main__":
    main()
