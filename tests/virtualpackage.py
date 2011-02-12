import sys
import imp

# fool import machinery into treating us like a package
__path__ = []

class EmptyImporter:
    @staticmethod
    def find_module(fullname, path=None):
        parts = fullname.split('.')
        if len(parts) == 2 and parts[0] == __name__:
            return EmptyImporter

    @staticmethod
    def load_module(fullname):
        if fullname in sys.modules:
            return sys.modules[fullname]
        
        parts = fullname.split('.')
        mod = imp.new_module(fullname)
        mod.__file__ = "<dummy>"

        sys.modules[fullname] = mod
        return mod

if EmptyImporter not in sys.meta_path:
    sys.meta_path.append(EmptyImporter)
