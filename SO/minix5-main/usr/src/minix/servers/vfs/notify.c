#include "fs.h"
#include "file.h"
#include "vnode.h"

static int procs[NR_NOTIFY];    // array for currently used proceses
static int curr;                // number of currently used VFS_NOTIFY calls
static mutex_t lock;

int notify_open(struct vnode *vnode) {
    suspend(FP_BLOCKED_ON_NOTIFY);
    return(SUSPEND);
}

int notify_triopen(struct filp *f) {

}

int notify_create(struct filp *f) {

}

int notify_move(struct filp *f) {

}

int do_notify(void) {
    int fd = job_m_in.m_lc_vfs_notify.fd;
    int event = job_m_in.m_lc_vfs_notify.event;
    if (event != NOTIFY_OPEN && event != NOTIFY_TRIOPEN && event != NOTIFY_CREATE && event != NOTIFY_MOVE)
        return EINVAL;
    struct filp *f = get_filp(fd, VNODE_NONE);
    struct vnode* v = f->filp_vno;
    if (f == NULL) return EBADF;
    if (!S_ISDIR(f->filp_vno->v_mode)) return ENOTDIR;

    if (curr_procs > NR_NOTIFY) {
        return ENONOTIFY;
    }
    curr_procs++;

    switch (event) {
        case NOTIFY_OPEN:
            return notify_open(v);
        case NOTIFY_TRIOPEN:
            return notify_triopen(v);
        case NOTIFY_CREATE:
            return notify_create(v);
        case NOTIFY_MOVE:
            return notify_move(v);
        default:
            curr_procs--;
            return EINVAL;
    }
}
