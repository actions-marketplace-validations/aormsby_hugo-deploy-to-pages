#!/bin/sh

AUTO_COMMIT_DEFAULT_HEADER="Action auto-build #${LAST_BUILD_NUMBER}"
AUTO_COMMIT_MESSAGE_BODY=$(printf '%s,\n%s,\n%s' "${AUTO_COMMIT_DEFAULT_HEADER}" "Built from branch '${INPUT_SOURCE_BRANCH}'" "Commit hash '${LAST_HASH}'")

set_commit_message() {
    if [ -z "${INPUT_COMMIT_MESSAGE}" ]; then
        COMMIT_MESSAGE="${AUTO_COMMIT_DEFAULT_HEADER}"
    else
        COMMIT_MESSAGE="${INPUT_COMMIT_MESSAGE}"
    fi

    COMMIT_MESSAGE=$(printf '%s\n\n%s' "${COMMIT_MESSAGE}" "${AUTO_COMMIT_MESSAGE_BODY}")
}

commit_build() {
    #submodule first
    if [ "${PUBLISH_TO_SUBMODULE}" ]; then
        commit_with_message "${INPUT_HUGO_PUBLISH_DIRECTORY}"
    fi

    # root project
    commit_with_message "."
}

commit_with_message() {
    # required steps to include all changes
    git -C "${1}" add --all
    git -C "${1}" commit -m "${COMMIT_MESSAGE}"
    COMMAND_STATUS=$?

    if [ "${COMMAND_STATUS}" != 0 ]; then
        # exit on git commit fail
        write_out "${COMMAND_STATUS}" "Git commit step failed. Check output and try again."
    fi
}

tag_release() {
    write_out -1 "Tagging release with build number." 1>&1
    git tag -a "auto-${LAST_BUILD_NUMBER}" -m "Auto-build #${LAST_BUILD_NUMBER}"
}

deploy_to_remote() {
    # can always use --set-upstream because if branch already exists it does nothing
    git push --set-upstream --recurse-submodules=on-demand --follow-tags origin "${INPUT_RELEASE_BRANCH}"
    COMMAND_STATUS=$?

    if [ "${COMMAND_STATUS}" != 0 ]; then
        # exit on push fail
        write_out "${COMMAND_STATUS}" "Unable to push commit to branch '${INPUT_RELEASE_BRANCH}'. Check output and try again."
    fi

    write_out -1 "Push to release branch complete"
    write_out "g" "SUCCESS\n"
}
