//
//  main.c
//  desktopBeGone
//
//  Created by Gregory Ling on 5/3/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

#include <stdio.h>
#include <dirent.h>

int main(int argc, const char * argv[]) {
    // insert code here...
    DIR * dirp = opendir(path);
    dirent * dp;
    while ( (dp = readdir(dirp)) !=NULL ) {
         cout << dp->d_name << " size " << dp->d_reclen<<std::endl;
    }
    (void)closedir(dirp);
    
    return 0;
}
