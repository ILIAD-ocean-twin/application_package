import sys
import logging
import click

MODEL_NAME = "[HELLOWORLD]"

logging.basicConfig(
    stream=sys.stderr,
    level=logging.DEBUG,
    format="%(asctime)s %(levelname)-8s %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
)


@click.command()
@click.option("--name", "-n", "name", help="name", required=True)
def main(name):

    logging.info(f"{MODEL_NAME} Process started")
    message = (
        "Hello "
        + name
        + " from python "
        + str(sys.version_info[0])
        + "."
        + str(sys.version_info[1])
        + "."
        + str(sys.version_info[2])
        + "!\n"
    )
    result = "result.txt"
    f = open(result, "a")
    f.write(message)
    f.close()

    logging.info(f"{MODEL_NAME} result: {message}")
    logging.info(f"{MODEL_NAME} Process finished!")


if __name__ == "__main__":
    main()
