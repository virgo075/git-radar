scriptDir="$(cd "$(dirname "$0")"; pwd)"

source "$scriptDir/git-base.sh"

#  X          Y     Meaning
#  -------------------------------------------------
#            [MD]   not updated
#  M        [ MD]   updated in index
#  A        [ MD]   added to index
#  D         [ M]   deleted from index
#  R        [ MD]   renamed in index
#  C        [ MD]   copied in index
#  [MARC]           index and work tree matches
#  [ MARC]     M    work tree changed since index
#  [ MARC]     D    deleted in work tree
#  -------------------------------------------------
#  D           D    unmerged, both deleted
#  A           U    unmerged, added by us
#  U           D    unmerged, deleted by them
#  U           A    unmerged, added by them
#  D           U    unmerged, deleted by us
#  A           A    unmerged, both added
#  U           U    unmerged, both modified
#  -------------------------------------------------
#  ?           ?    untracked
#  !           !    ignored
#  -------------------------------------------------

test_basic_unstaged_options() {
  status="""
 M modified-and-unstaged
 D deleted-and-unstaged
 A impossible-added-and-unstaged-(as-added-and-unstaged-is-untracked)
 C impossible-copied-and-unstaged-(as-copied-and-unstaged-is-untracked)
 R impossible-renamed-and-unstaged-(as-renamed-and-unstaged-is-untracked)
 U impossible-updated-but-unmerged
 ! impossible-ignored-without-!-in-position-1
 ? impossible-untracked-without-?-in-position-1
   empty-spaces-mean-nothing
  """
  assertEquals "line:${LINENO} staged status failed match" "" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match"\
    "1${unstaged}${deleted}1${unstaged}${modified}" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"
}

test_basic_staged_options() {
  status="""
A  added-and-staged
  """
  assertEquals "line:${LINENO} staged status failed match"\
    "1${staged}${added}" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"

  status="""
M  modified-and-staged
  """
  assertEquals "line:${LINENO} staged status failed match"\
    "1${staged}${modified}" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"

  status="""
D  deleted-and-staged
  """
  assertEquals "line:${LINENO} staged status failed match"\
    "1${staged}${deleted}" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"

  status="""
C  copied-and-staged
  """
  assertEquals "line:${LINENO} staged status failed match"\
    "1${staged}${copied}" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"

  status="""
R  renamed-and-staged
  """
  assertEquals "line:${LINENO} staged status failed match"\
    "1${staged}${renamed}" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"

  status="""
U  impossible-unmerged-without-a-character-in-position-2
?  impossible-untracked-without-?-in-position-2
!  impossible-ignored-without-!-in-position-2
   empty-spaces-do-nothing
  """
  assertEquals "line:${LINENO} staged status failed match" "" "$(staged_status "$status")"
  assertEquals "line:${LINENO} untracked status failed match" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO} unstaged status failed match" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO} conflicted status failed match" "" "$(conflicted_status "$status")"
}

test_conflicts() {
  status="""
UD unmerged-deleted-by-them
UA unmerged-added-by-them
  """
  assertEquals "line:${LINENO}" "" "$(staged_status "$status")"
  assertEquals "line:${LINENO}" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO}" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO}" "2${conflicted}${them}" "$(conflicted_status "$status")"

  status="""
AU unmerged-added-by-us
DU unmerged-deleted-by-us
  """
  assertEquals "line:${LINENO}" "" "$(staged_status "$status")"
  assertEquals "line:${LINENO}" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO}" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO}" "2${conflicted}${us}" "$(conflicted_status "$status")"

  status="""
AA unmerged-both-added
DD unmerged-both-deleted
UU unmerged-both-modified
  """
  assertEquals "line:${LINENO}" "" "$(staged_status "$status")"
  assertEquals "line:${LINENO}" "" "$(untracked_status "$status")"
  assertEquals "line:${LINENO}" "" "$(unstaged_status "$status")"
  assertEquals "line:${LINENO}" "3${conflicted}${both}" "$(conflicted_status "$status")"
}

. ./shunit/shunit2