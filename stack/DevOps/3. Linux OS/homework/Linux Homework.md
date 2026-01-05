# Linux Homework

## Exercise 1: Basic Commands
1. Define a variable named `FILENAME` and give it a value of `/tmp/test1`
2. Create the file defined in the `FILENAME` variable if it doesn't already
exist and give it `777` permissions.
3. Check if the file is owned by the script user. If not, print a message and
change the ownership.
4. Store the number of lines in the file in a variable. Print `no lines` if the 
file is empty, or the numer of lines if it contains text.

## Exercise 2: Loops
1. Write a script that calculates the sum of odd numbers from 0 to 100 and prints it.
2. Divide the sum by 100. What do you notice?
3. Write a script that generates 5 random numbers that are divisible by 2, but not 
by 3.

## Exercise 3: Arrays
1. Declare 2 arrays, `ro_cars` with 2 elements `Dacia` and `Aro`, and `de_cars` with 3
elements `BMW`, `Audi`, and `Mercedes`.
2. Append `Opel` to the `de_cars` array.
3. Merge the 2 arrays into a new array named `cars`.
4. Remove `Aro` from the `cars` array.
5. Create an associative array, with `name` as key and country as value, containing
all cars.
6. Print `Brand name: <name>, Country of origin: <country>` for each car in the 
associative array.

## Exercise 4: Script options
1. Write a script that takes any number of strings as command line arguments and
prints the first one, as it would be sorted in alphabetical order.
2. Check if variable `LAST` is set. If it is, the last should be taken instead of 
the first.
3. Make teh script also accept a `-l` (no value) option that will have the same
effect as setting the `LAST` variable and override it if it's already set.

## Exercise 5: User management
1. Create a script that prompts the user for a user name. Check if the user exists,
and print a red error message if it doesn't.
2. Get the home of the user and login shell from `/etc/passwd` and print them.
3. Create a file named `me.sh` in the user's home directory which contains only one
line `export ME=$(whoami)` and shebang line with the user's login shell. Also set
the ownership and permissions.
4. If current script is running as selected user or root, run the `me.sh` with source
as then check the environment for `ME` variable and print it.

## Exercise 6:
1. Create a function that tales a number of strings as arguments and concatenates
them into a single string.
2. Create a function that receives a number of strings and populates an associative
array that contains only teh strings that have under 3 characters, with
`<value> : <length>`.
3. Have a script with a main function that passes the script arguments to both
previous functions.
4. Make sure the whole script does error handling and prints useful messages.
5. Compare the number of characters in the results from the functions and display a 
message with its findings.

## Exercise 7: File manipulation
1. Create a heredoc with: 
```
Hello $user!
Please log off from ${machine} in 5 minutes!
This machine has been ${running}.
```
2. `$user` should be the first parameter to the script, if not set use `user`. 
Capitalize the first letter.
3. `$machine` should be the full hostname, but strip anything after the first `.`.
4. `$running` should be taken from `uptime --pretty` command, but `up` should be
replaced with `running for`.
5. Save the resulting message in `/tmp/message.txt` and set the permissions to `600`.

## Exercise 8: Monitoring
1. Create a script that will alert when your mounts are out of space.
2. Check disk space and print a message if less than 20% is available, one per line
for each mount.
3. Add option for teh percent needed to be passed as a short form option with
`-p <percent>`.
4. Add a `-m` which specifies a size in MB, under which the mount will be added to
the report, no matter the percentage.
5. Add a `-e` option that will exclude any mount that has the specified string
in its name. `-e` can be specified multiple times.

## Exercise 9: Find and process
1. Find and print the size of all files smaller than 20K in a directory and copy
them to `/tmp/smallfiles` directory. Do not include subdirectories in the search.
2. Every 5 seconds show the environment variable of all process of all bash
session of the current user sorted by start time.
3. List all other files that are in the same base directory as the `sh` executable's
symlink whose name starts with `git`.

## Exercise 10: Script metadata and backup
1. Create a script named `backup.sh` that takes one argument as the `target_file` to
operate on.
2. If no argument is provided, then the script filename itself is considered the
`target_file`.
3. Copy the `target_file` to `/tmp/backup` directory. If the file already exists in
the location, move it to `<target_file>_old`.
4. Inject the following "header" lines with value discovered on the initial script:
```
# Owner: <value>
# Permsissions: <value>
# Changed Date: <value>
```
5. Archive and compress the backup file into a file named 
`<target_file>_<timestamp>.tar.gz`.
6. If instead of a file, a directory name is passed as argument, then backup
all files eith extensions `.sh`, `.txt` or `.log` in a single archive.
