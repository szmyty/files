# Use the official MegaLinter image as the base
FROM oxsecurity/megalinter:latest

# Install lxml using pip
RUN pip3 install lxml


RUN cd /venvs/mypy \
    && virtualenv . \
    && source bin/activate \
    && PYTHONDONTWRITEBYTECODE=1 pip3 install --no-cache-dir lxml numpy pydantic \
    && deactivate

# ENTRYPOINT [ "tail", "-f", "/dev/null" ]
