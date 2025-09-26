import os
import sys
import logging

MODEL_NAME = "[HELLOWORLD]"

logging.basicConfig(
    stream=sys.stderr,
    level=logging.DEBUG,
    format="%(asctime)s %(levelname)-8s %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
)

def main():

    logging.info(f"{MODEL_NAME} Process started")
    message = (
        "Hello "
        + " from python "
        + str(sys.version_info[0])
        + "."
        + str(sys.version_info[1])
        + "."
        + str(sys.version_info[2])
        + "!\n"
    )

    # this is the writable directory (./ = $HOME)
    result = "result.txt"
    f = open(result, "a")
    f.write(message)
    f.close()

    # this is /tmp dir that is writable
    result = "/tmp/result.txt"
    f = open(result, "a")
    f.write(message)
    f.close()

    # this is $HOME dir that is writable
    result = f"/{os.environ['HOME']}/result.txt"
    f = open(result, "a")
    f.write(message)
    f.close()

    logging.info(f"{MODEL_NAME} result: {message}")
    logging.info(f"{MODEL_NAME} Process finished!")


if __name__ == "__main__":
    main()