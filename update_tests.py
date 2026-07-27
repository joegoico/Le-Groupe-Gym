import os
import re

directory = 'test'
for root, dirs, files in os.walk(directory):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                lines = f.readlines()
            
            new_lines = []
            skip = False
            for line in lines:
                if 'aplicaDescuento: true' in line or 'aplicaDescuento: false' in line or 'aplicaDescuento: alumno.aplicaDescuento' in line:
                    continue
                if 'expect(guardado!.aplicaDescuento' in line or 'expect(alumno.aplicaDescuento' in line:
                    continue
                if 'debe incluir aplicaDescuento=true al activar el switch' in line:
                    skip = True
                
                if skip:
                    if '});' in line:
                        skip = False
                    continue
                
                new_lines.append(line)
            
            if len(new_lines) != len(lines):
                with open(filepath, 'w') as f:
                    f.writelines(new_lines)
                print(f'Updated {filepath}')

