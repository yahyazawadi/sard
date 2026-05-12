
def fix_home():
    path = r'c:\Users\CLICK\Desktop\sard\lib\screens\home_screen.dart'
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Remove line 532 (index 531) if it's ); and 531 is ),
    if lines[531].strip() == ');' and lines[530].strip() == '),':
        lines[530] = lines[530].replace('),', ');')
        del lines[531]
        
    with open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)

def fix_main():
    path = r'c:\Users\CLICK\Desktop\sard\lib\screens\main_wrapper_screen.dart'
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    # Re-write the bottom of build method
    # Find the destinations list and close properly
    # This is more complex, I'll just find the last NavigationBar and close it.
    pass

fix_home()
