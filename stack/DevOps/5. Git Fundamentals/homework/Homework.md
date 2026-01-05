# Homework

## Tips

If at any point you get stuck, after doing your own investigation (avoid investing a huge amount of time in a particular issue), ask your colleagues, and then your mentors for an opinion.

## [Create a Repo](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository)

- Create a new repository in GitLab (aka Project) and synchronize it locally
  - by initializing it remotely and cloning it locally
  - or by creating it empty on the remote and pushing a locally initialized repo to the remote

## [GitIgnore](https://www.atlassian.com/git/tutorials/saving-changes/gitignore)

- Create three directiories under your new repo named `Folder1`, `Folder2`, and `Folder3`.
- Create a file under `Folder2` named `File2` and two more under `Folder3` named `File31` and `File32`.
- Find a way to avoid accidentally commiting `File2` to the repo.
- Now do the same for the directory `Folder3`.
- Commit and push your  changes to the remote  repository.

## [GitKeep](https://www.theserverside.com/blog/Coffee-Talk-Java-News-Stories-and-Opinions/gitkeep-push-empty-folders-git-commit)

- Find a way to push the empty directory `Folder1` to the remote repository

## [Branching and Merging](https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging)

### Fast Forward merge

- Create a new branch called **topic** based on **main**
- Create a new file called `File1.txt` then commit it
- Switch to main and merge the **topic** onto **main**
- Check the commits with `git log`

### No FF merge

- While still on **main**, create and commit a new file called `File2.txt`
- Checkout **topic** and commit some changes to `File1.txt`
- Move back on **main** and merge **topic** again into **main**
- Check the commits with `git log` and notice what's new this time

### [Merging with conflicts](https://www.atlassian.com/git/tutorials/using-branches/merge-conflicts)

- While still on **main** commit some random changes to `File1.txt`
- Checkout **topic** and commit some other random changes to `File1.txt`
- Move back on **main** and merge **topic** again into **main**
- Resolve the conflict by accepting incoming changes (override **main** with **topic**)
- Commit the updated file
- Check the commits with `git log` and notice what's new this time

## [Pull/Merge Requests](https://docs.gitlab.com/ee/user/project/merge_requests/)

- While still on **main** push your changes on remote
- Checkout **topic** and run `git rebase main` to bring all the missing changes from **main** to **topic**
- Commit some random changes to `File1.txt`
- Push **topic** on remote | (create a new upstream branch)
- Go to your GitLab Project page and navigate to the *Merge requests* section
- Create a new Merge Request from **topic** to **main** while inspecting all the different options that you have
- Press the green Merge button to take the changes from **topic** to **main**
