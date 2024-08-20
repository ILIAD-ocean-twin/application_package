import sys

def main(args=sys.argv):

    if len(args) < 2:
        print("Please provide a name as an argument.")
        return
    
    message = (
        "Hello "
        + args[1]
        + " from python "
        + str(sys.version_info[0])
        + "."
        + str(sys.version_info[1])
        + "."
        + str(sys.version_info[2])
        + "!\n"
    )
    print(message)

if __name__ == "__main__":
    main()