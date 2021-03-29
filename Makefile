# file for local make file stuff
# Good for secrets that don't need to be in the source code
-include Makefile.local.mk
export SOME_SECRET=asdfasdf


VENV_PREFIX ?= poetry run

init-dev: init-venv setup-pre-commit  ## setup environment and install dependencies for local development

install-poetry:
	python3.8 -m pip install --upgrade poetry

init-venv:
	poetry install

setup-pre-commit:
	git init
	$(VENV_PREFIX) pre-commit install --hook-type pre-commit
	$(VENV_PREFIX) pre-commit install --hook-type pre-push
	$(VENV_PREFIX) pre-commit install --hook-type commit-msg
  
lint: flake8 pylint mypy black-check isort-check docstring-check commit-check  ## run linters

pylint:
	$(VENV_PREFIX) pylint ml_fusion_tcb run.py
	$(VENV_PREFIX) pylint --disable=redefined-outer-name,protected-access,not-callable tests

mypy:
	$(VENV_PREFIX) mypy

flake8:
	$(VENV_PREFIX) flake8

black-check:
	$(VENV_PREFIX) black . --check

isort-check:
	$(VENV_PREFIX) isort --atomic --check-only .

docstring-check:
	$(VENV_PREFIX) pydocstyle ml_fusion_tcb
  
reformat:  ## run black and isort to reformat the project
	$(VENV_PREFIX) black .
	$(VENV_PREFIX) isort --atomic .

test:  ## run tests using pytest
	$(VENV_PREFIX) pytest -vv

coverage:  ## report test coverage
	$(VENV_PREFIX) pytest --cov-report term-missing --cov-report xml --cov=ml_fusion_tcb tests

secure:  ## run security check
	$(VENV_PREFIX) safety check --full-report --cache
	$(VENV_PREFIX) bandit -iii -lll -r ml_fusion_tcb
  
commit-check:
	# Skip if NO_COMMIT_FOUND is raised
	$(VENV_PREFIX) cz check --rev-range origin/master.. || \
	if [ $$? != 3 ]; then \
		exit 14; \
	fi
