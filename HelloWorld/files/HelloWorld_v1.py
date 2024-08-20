import sys
import click

@click.command()

@click.option("--name", "-n", "name", help="name", required=True)

def main(name):

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
    print(message)


if __name__ == "__main__":
    main()
