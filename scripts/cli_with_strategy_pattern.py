import os
import click
import logging
from abc import ABC, abstractmethod

# Setup function
def setup():
    """Global setup tasks for logging."""
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(levelname)s - %(message)s",
    )
    logging.info("Application setup complete.")

# Strategy Pattern: Abstract Ingest Strategy
class IngestStrategy(ABC):
    """Abstract base class for ingestion strategies."""

    @abstractmethod
    def ingest(self, host):
        """Perform the ingestion."""
        pass

# Concrete Strategies
class ProcedureIngestStrategy(IngestStrategy):
    """Strategy for ingesting procedure documents."""

    def ingest(self, host):
        logging.info(f"Ingesting procedure documents using host: {host}")
        click.echo(f"Procedure ingestion complete (host: {host}).")

class PolicyIngestStrategy(IngestStrategy):
    """Strategy for ingesting policy documents."""

    def ingest(self, host):
        logging.info(f"Ingesting policy documents using host: {host}")
        click.echo(f"Policy ingestion complete (host: {host}).")

class MiscellaneousIngestStrategy(IngestStrategy):
    """Strategy for ingesting miscellaneous documents."""

    def ingest(self, host):
        logging.info(f"Ingesting miscellaneous documents using host: {host}")
        click.echo(f"Miscellaneous ingestion complete (host: {host}).")

# Factory Method for Strategy Determination
class IngestStrategyFactory:
    """Factory for creating ingestion strategies based on flags."""

    @staticmethod
    def get_strategies(procedures, policies, miscellaneous):
        strategies = []
        if procedures:
            strategies.append(ProcedureIngestStrategy())
        if policies:
            strategies.append(PolicyIngestStrategy())
        if miscellaneous:
            strategies.append(MiscellaneousIngestStrategy())
        return strategies

# Context Class for Switching Strategies
class Ingestor:
    """Context for managing ingestion strategies."""

    def __init__(self, strategies):
        self.strategies = strategies

    def run(self, host):
        """Execute all strategies in sequence."""
        for strategy in self.strategies:
            strategy.ingest(host)

# Root CLI group
@click.group()
@click.option(
    "--host",
    default=lambda: os.getenv("DEFAULT_HOST", "http://localhost"),
    help="Set the host URL (default loaded from environment).",
)
@click.pass_context
def cli(ctx, host):
    """Main CLI tool."""
    setup()
    ctx.ensure_object(dict)  # Ensure context object is a dictionary
    ctx.obj["HOST"] = host  # Store the host in the context
    logging.info(f"Using host: {host}")

# Ingest command
@cli.command()
@click.option("--procedures", is_flag=True, help="Ingest procedure documents.")
@click.option("--policies", is_flag=True, help="Ingest policy documents.")
@click.option("--miscellaneous", is_flag=True, help="Ingest miscellaneous documents.")
@click.pass_context
def ingest(ctx, procedures, policies, miscellaneous):
    """Ingest documents."""
    host = ctx.obj["HOST"]
    logging.info("Starting ingestion process...")

    # Determine strategies based on flags
    strategies = IngestStrategyFactory.get_strategies(procedures, policies, miscellaneous)

    # Default: Run all if no flags are provided
    if not strategies:
        logging.info("No specific flags provided. Running all ingestions.")
        strategies = [
            ProcedureIngestStrategy(),
            PolicyIngestStrategy(),
            MiscellaneousIngestStrategy(),
        ]

    # Create the context and execute strategies
    ingestor = Ingestor(strategies)
    ingestor.run(host)

    logging.info("Ingestion process complete.")

# Execute CLI
if __name__ == "__main__":
    cli()
