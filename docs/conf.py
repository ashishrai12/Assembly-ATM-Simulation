import os
import sys
sys.path.insert(0, os.path.abspath('..'))

project = 'Assembly ATM Simulation'
copyright = '2026, Ashish Rai'
author = 'Ashish Rai'
release = '0.1.0'

extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.napoleon',
    'myst_parser',
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

html_theme = 'alabaster'
html_static_path = ['_static']
