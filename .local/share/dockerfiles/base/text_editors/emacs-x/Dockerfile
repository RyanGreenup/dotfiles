FROM localhost/text_editors


# Remove the pgtk variant from the text_editors image
RUN rm -rf /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:deathwish:emacs-pgtk-nativecomp.repo && \
    dnf remove -y emacs && \
    dnf update -y
# Install the default fedora one (X11 with NativeComp)
RUN dnf install -y emacs
