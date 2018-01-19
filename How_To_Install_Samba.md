# Install Samba  

    [global]  
    username map = /etc/samba/smbusers  
    
    [YourFolder]  
    comment = Your Comment  
    path = /your/path  
    browseable = yes  
    writeable = yes  
    guest ok = no  
    read only = no  
    valid users = user1, user2  
    admin users = user1, user2  
    force user = user1  
    force group = user1  

    # Bash command  
    sudo pdbedit -L
    sudo pdbedit -x deleteYourUser # Delete user
    sudo smbpasswd -a createYourUser # Create user  
    sudo smbpasswd yourUserName # Modify password  

# Windows credentials manage  

    net use /delete \\yourhost\dirname  
    net use  
    net use /user:yourUserName \\yourhost\dirname yourPassword  
  
# Tips

1. Restart your process 'explorer.exe'  
2. Windows key > Control panel > User accounts > Manage your credentials > Windows credentials > Remove server credentials  
3. Ctrl + R > rundll32.exe keymgr.dll, KRShowKeyMgr  
4. klist purge  
