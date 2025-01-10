import os
import sys
import atexit
import click
import logging

# Setup function
def setup():
    """Global setup tasks for logging and cleanup hooks."""
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
    )
    logging.info("Application setup complete.")

    # Register cleanup tasks
    def on_exit():
        logging.info("Application is shutting down. Performing cleanup tasks.")

    atexit.register(on_exit)

# Root CLI group
@click.group()
@click.option(
    "--host",
    default=lambda: os.getenv("DEFAULT_HOST", "http://localhost"),
    help="Set the host URL (default loaded from environment).",
)
@click.option(
    "--hello",
    is_flag=True,
    help="Say hello before doing anything else.",
)
@click.pass_context
def cli(ctx, host, hello):
    """Main CLI tool."""
    setup()
    ctx.ensure_object(dict)  # Ensure context object is a dictionary
    ctx.obj["HOST"] = host  # Store the host in the context
    ctx.obj["HELLO"] = hello  # Store the hello flag in the context

    if hello:
        logging.info("Hello, World!")
        click.echo("Hello, World!")

    logging.info(f"Using host: {host}")


# Ingest command
@cli.command()
@click.option("--procedures", is_flag=True, help="Ingest procedure documents.")
@click.option("--policies", is_flag=True, help="Ingest policy documents.")
@click.pass_context
def ingest(ctx, procedures, policies):
    """Ingest documents."""
    host = ctx.obj["HOST"]
    logging.info("Starting ingestion process...")

    # Determine what to run
    if not procedures and not policies:
        # Default: Run all ingestions
        logging.info("No specific flags provided. Running all ingestions.")
        ingest_procedures(host)
        ingest_policies(host)
    else:
        # Run only the specified ingestions
        if procedures:
            ingest_procedures(host)
        if policies:
            ingest_policies(host)

    logging.info("Ingestion process complete.")


# Ingest procedures
def ingest_procedures(host):
    """Simulate ingestion of procedure documents."""
    logging.info(f"Ingesting procedure documents using host: {host}")
    click.echo(f"Procedure ingestion complete (host: {host}).")


# Ingest policies
def ingest_policies(host):
    """Simulate ingestion of policy documents."""
    logging.info(f"Ingesting policy documents using host: {host}")
    click.echo(f"Policy ingestion complete (host: {host}).")


# Placeholder for future group
@cli.group()
def process():
    """(Placeholder) Commands related to data processing."""
    click.echo("Process commands are not yet implemented.")


# Wrapper for handling top-level exceptions
def main_wrapper():
    """Wrapper for executing the main CLI with error handling."""
    try:
        cli(standalone_mode=False)  # Prevent Click from crashing on Colab's extra arguments
    except SystemExit as e:
        sys.exit(e.code)  # Gracefully handle SystemExit
    except Exception as e:
        logging.critical(f"Unhandled exception occurred: {e}", exc_info=True)


# Execute CLI
if __name__ == "__main__":
    main_wrapper()
