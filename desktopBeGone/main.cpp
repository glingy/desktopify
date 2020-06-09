//
//  main.cpp
//  desktopBeGone
//
//  Created by Gregory Ling on 5/3/20.
//  Copyright © 2020 Gregory Ling. All rights reserved.
//

#include <stdio.h>
#include <string>
#include <iostream>
#include <filesystem>
#include <unistd.h>
#include <pwd.h>

namespace fs = std::filesystem;

int main() {
    uid_t uid = getuid();
    struct passwd *pw = getpwuid(uid);

    if (pw == NULL) {
            printf("Failed\n");
            exit(EXIT_FAILURE);
    }

    printf("%s\n", pw->pw_dir);
    std::string path = pw->pw_dir;
    for (const auto & entry : fs::directory_iterator(path))
        std::cout << entry.path() << std::endl;
}
