from pathlib import Path
path = Path(r'C:\Users\PHAREL\StudioProjects\novaschool\lib\core\network\api_client.dart')
text = path.read_text(encoding='utf-8', errors='replace')
for i,line in enumerate(text.splitlines()):
    if i==22:
        print(repr(line))
        print([ord(c) for c in line])
