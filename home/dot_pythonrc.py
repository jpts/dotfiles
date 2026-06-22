import sys
from pathlib import Path

ver = sys.version.split(" ")[0]
minor = ".".join(ver.split(".")[:2])
home = Path.home()
for p in [
            f".asdf/installs/python/{ver}/lib/python{minor}/site-packages",
            f".local/lib/python{minor}/site-packages"
        ]:
    path = home.joinpath(p)
    sys.path.append(str(path))

# ===
try:
    from rich import pretty
    pretty.install()
except:
    print("Pretty init failed")

try:
    import readline
except ImportError:
    print("Module readline not available.")
else:
    readline.parse_and_bind("tab: complete")


def reload_package(package):
    import os
    import types
    import importlib

    assert(hasattr(package, "__package__"))
    fn = package.__file__
    fn_dir = os.path.dirname(fn) + os.sep
    module_visit = {fn}
    del fn

    def reload_recursive_ex(module):
        importlib.reload(module)

        for module_child in vars(module).values():
            if isinstance(module_child, types.ModuleType):
                fn_child = getattr(module_child, "__file__", None)
                if (fn_child is not None) and fn_child.startswith(fn_dir):
                    if fn_child not in module_visit:
                        # print("reloading:", fn_child, "from", module)
                        module_visit.add(fn_child)
                        reload_recursive_ex(module_child)

    return reload_recursive_ex(package)
