# AudioShift distribution site

This is the local GitHub Pages repository prepared for the future
`xFayez95/audioshift` repository.  Do not publish it until its URLs, release
notes, and installer have been reviewed.

GitHub Pages serves `docs/`; GitHub Releases serve the package asset.  The
installer always downloads the stable release filename
`audioshift-dreamos.deb`.

Local test after creating the remote repository:

```sh
git init
git branch -M main
git add docs .gitignore README.md
git commit -m "Initial AudioShift distribution site"
git remote add origin https://github.com/xFayez95/audioshift.git
# Review before: git push -u origin main
```
