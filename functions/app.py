import fastapi
import pydantic
import re
import os
import json
from fastapi.staticfiles import StaticFiles
from fastapi import FastAPI, Response
import dtlpy as dl

app = FastAPI()


class Context(pydantic.BaseModel):
    project_id: str
    dataset_id: str
    dataset_name: str
    project_name: str
    notebook_path: str


def process_notebook(context: dict, notebook_path: str):
    if notebook_path == '/tmp/notebook_path':
        return
    """
    Process the input notebook to replace variable values and save to the output path.
    """
    for variable_name, new_value in context.items():
        # Regular expression for finding the variable assignment
        # This regex handles simple assignments. It may need to be adjusted for complex scenarios.
        pattern1 = rf"({variable_name}\s*=\s*)'[^']+'"
        pattern2 = rf"({variable_name}\s*=\s*)'[^']+'"

        with open(notebook_path, 'r', encoding='utf-8') as f:
            notebook = json.load(f)

        for cell in notebook['cells']:
            if cell['cell_type'] == 'code':  # Process only code cells
                original_source = ''.join(cell['source'])
                exists = re.findall(pattern1, original_source)
                if len(exists) > 0:
                    print(exists)
                exists = re.findall(pattern2, original_source)
                if len(exists) > 0:
                    print(exists)
                original_source = re.sub(pattern1, r"\g<1>'" + new_value + "'", original_source)
                original_source = re.sub(pattern2, r"\g<1>'" + new_value + "'", original_source)
                cell['source'] = original_source.splitlines(True)  # Split into lines preserving line endings

        with open(notebook_path, 'w', encoding='utf-8') as f:
            json.dump(notebook, f, indent=2)


@app.get("/api/hello")
def hello():
    return {"hi": "whaaaa"}


@app.post("/api/update-context")
def replace(context: Context, ):
    print(f'income: {context}')
    context = context.model_dump()
    print(f'dict: {context}')

    notebook_path = os.path.join(os.path.expanduser("~"), context.pop('notebook_path', ''))
    process_notebook(context=context, notebook_path=notebook_path)
    return {"status": "success"}


app.mount("/notebooks", StaticFiles(directory="/tmp/app/panels/notebooks", html=True), name="notebooks")
