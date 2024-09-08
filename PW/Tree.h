#include "HashMap.h"
#include "path_utils.h"
#include "err.h"
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <pthread.h>
#include <strings.h>
#include <string.h>

struct Tree {
    HashMap *hm;
    char* name;
    pthread_mutex_t lock;
};


typedef struct Tree Tree; // Let "Tree" mean the same as "struct Tree".

Tree* tree_new() {
    Tree *tree = malloc (sizeof(Tree));
    tree->hm = hmap_new();
    tree->name = malloc(sizeof(char));
    strcpy(tree->name, "");

    int err;
    if ((err = pthread_mutex_init(&tree->lock, 0)) != 0)
        syserr (err, "mutex init failed");
    return tree;
}

void tree_free(Tree* tree) {
    const char* key;
    void* value;
    HashMapIterator it = hmap_iterator(tree->hm);
    while (hmap_next(tree->hm, &it, &key, &value)) {
        tree_free(value);
    }

    int err;
    if ((err = pthread_mutex_destroy (&tree->lock)) != 0)
        syserr (err, "mutex destroy failed");

    hmap_free(tree->hm);
    free(tree->name);
    free(tree);
}

Tree* find_node(Tree* tree, const char* path, bool lock) {
    int err;

    char component[MAX_FOLDER_NAME_LENGTH + 1];
    const char* subpath = path;
    Tree *start = tree;
    Tree *next;
    if (lock && (err = pthread_mutex_lock(&tree->lock)) != 0)
        syserr (err, "lock failed");
    while (subpath = split_path(subpath, component)) {
        next = hmap_get(tree->hm, component);
        //  printf("find %s\n", path);
        if (next == NULL) {
            if ((lock || start != tree) && (err = pthread_mutex_unlock(&tree->lock)) != 0)
                syserr (err, "unlock failed");
            return NULL;
        }
        if ((err = pthread_mutex_lock(&next->lock)) != 0)
            syserr (err, "lock failed");

        if ((lock || start != tree) && (err = pthread_mutex_unlock(&tree->lock)) != 0)
            syserr (err, "unlock failed");
        tree = next;
    }
    // without unlock at the end
    return tree;
}

int len(char* path) {
    int len = 0;
    while (path[len] != '\0') {
        len++;
    }
    return len;
}

char* tree_list(Tree* tree, const char* path) {
    int err;

    if (!is_path_valid(path)) return EINVAL;

    tree = find_node(tree, path, true);
    if (tree == NULL) return NULL;

    char *list = make_map_contents_string(tree->hm);

    if ((err = pthread_mutex_unlock(&tree->lock)) != 0)
        syserr (err, "unlock failed");

    return list;
}

int tree_create(Tree* tree, const char* path) {
    int err;

    if (!is_path_valid(path)) return EINVAL;
    if (path[0] == '/' && path[1] == '\0' ) return EEXIST;
    char child[MAX_FOLDER_NAME_LENGTH + 1];
    char* parent = make_path_to_parent(path, child);

    tree = find_node(tree, parent, true);
    free(parent);
    if (tree == NULL) {
        return ENOENT;
    }


    Tree *new = malloc(sizeof(Tree));
    new->name = malloc( sizeof(char *) *(len(child) + 1));
    printf("%d\n", len(child));
    strncpy(new->name, child, len(child));
    new->name[len(child)] = '\0';


    if (hmap_get(tree->hm, new->name) != NULL) {
        if ((err = pthread_mutex_unlock(&tree->lock)) != 0)
            syserr (err, "unlock failed");
        free(new->name);
        free(new);
        return EEXIST;
    }

    new->hm = hmap_new();
    hmap_insert(tree->hm, new->name, new);

    printf("%s added\n", new->name);
    if ((err = pthread_mutex_init(&new->lock, 0)) != 0)
        syserr (err, "mutex init failed");
    if ((err = pthread_mutex_unlock(&tree->lock)) != 0)
        syserr (err, "unlock failed");
    return 0;
}

int tree_remove(Tree* tree, const char* path) {
    int err;

    if (!is_path_valid(path)) return EINVAL;

    if (path[0] == '/' && path[1] == '\0') return EBUSY;

    char child[MAX_FOLDER_NAME_LENGTH + 1];
    char* parent = make_path_to_parent(path, child);

    tree = find_node(tree, parent, true);
    free(parent);
    if (tree == NULL){
        return ENOENT;
    }
    printf("%s child\n", child);
    Tree *tree_child = hmap_get(tree->hm, child);

    if (tree_child == NULL) {
        if ((err = pthread_mutex_unlock(&tree->lock)) != 0)
            syserr (err, "unlock failed");
        return ENOENT;
    }

    if ((err = pthread_mutex_lock(&tree_child->lock)) != 0)
        syserr (err, "lock failed");
    if (hmap_size(tree_child->hm) > 0) {
        if ((err = pthread_mutex_unlock(&tree->lock)) != 0)
            syserr (err, "unlock failed");
        if ((err = pthread_mutex_unlock(&tree_child->lock)) != 0)
            syserr (err, "unlock failed");
        return ENOTEMPTY;
    }
    if ((err = pthread_mutex_unlock(&tree_child->lock)) != 0)
        syserr (err, "unlock failed");
    tree_free(tree_child);  // jak tutaj odblokowac?
    hmap_remove(tree->hm, child);
    if ((err = pthread_mutex_unlock(&tree->lock)) != 0)
        syserr (err, "unlock failed");
    return 0;
}

struct PairOfNodes {
    Tree *parent;
    Tree *target;
};

typedef struct PairOfNodes PairOfNodes;

PairOfNodes null_pair() {
    PairOfNodes pair;
    pair.parent = NULL, pair.target = NULL;
    return pair;
}

PairOfNodes find_two_nodes(Tree* tree, const char* source, const char* target) {

    int err;

    char mutual[MAX_PATH_LENGTH + 1];
    int i = 0;
    for (i = 0; source[i] != '\0' && target[i] == source[i]; i++) {
        mutual[i] = source[i];
    }
    i--;
    while (mutual[i] != '/') {
        mutual[i] = '\0';
        i--;
    }
    mutual[i + 1] = '\0';

    if (source[i + 1] == '\0' || target[i + 1] == '\0') return null_pair();

    char component[MAX_FOLDER_NAME_LENGTH + 1];
    const char* subpath = mutual;
    Tree *next;
    if ((err = pthread_mutex_lock(&tree->lock)) != 0)
        syserr (err, "lock failed");
    while (subpath = split_path(subpath, component)) {
        source = split_path(source, NULL);
        target = split_path(target, NULL);
        next = hmap_get(tree->hm, component);

        if (next == NULL) {
            if ((err = pthread_mutex_unlock(&tree->lock)) != 0)
                syserr (err, "unlock failed");
            return null_pair();
        }
        if ((err = pthread_mutex_lock(&next->lock)) != 0)
            syserr (err, "lock failed");

        if ((err = pthread_mutex_unlock(&tree->lock)) != 0)
            syserr (err, "unlock failed");
        tree = next;
    }
    PairOfNodes pair = null_pair();
    pair.target = find_node(tree, target, false);
    if (pair.target == NULL) {
        if ((err = pthread_mutex_unlock(&tree->lock)) != 0)
            syserr(err, "unlock failed");
        return pair;
    }
    pair.parent = find_node(tree, source, false);
    if (pair.parent == NULL) {
        if ((err = pthread_mutex_unlock(&pair.target->lock)) != 0)
            syserr (err, "unlock failed");
        if ((err = pthread_mutex_unlock(&tree->lock)) != 0)
            syserr (err, "unlock failed");
        return null_pair();
    }
    if ((err = pthread_mutex_unlock(&tree->lock)) != 0)
        syserr (err, "unlock failed");
    return pair;
}

int tree_move(Tree* tree, const char* source, const char* target) {
    int err;

    if (!is_path_valid(source) || !is_path_valid(target)) return EINVAL;
    if (source[0] == '/' && source[1] == '\0') return EBUSY;
    if (target[0] == '/' && target[1] == '\0') return ENOENT;
    char child_prev[MAX_FOLDER_NAME_LENGTH + 1];
    char child_next[MAX_FOLDER_NAME_LENGTH + 1];

    char* parent_target = make_path_to_parent(target, child_next);
    char *parent_source = make_path_to_parent(source, child_prev);

    PairOfNodes pair = find_two_nodes(tree, parent_source, parent_target);
    free(parent_source);
    free(parent_target);
    Tree *target_tree = pair.target;
    Tree *parent_tree = pair.parent;
    if (target_tree == NULL || parent_tree == NULL){
        return ENOENT;
    }
    Tree *source_tree = hmap_get(parent_tree->hm, child_prev);
    if (hmap_get(target_tree->hm, child_next) != NULL || source_tree == NULL) {
        if ((err = pthread_mutex_unlock(&target_tree->lock)) != 0)
            syserr (err, "unlock failed");
        if ((err = pthread_mutex_unlock(&parent_tree->lock)) != 0)
            syserr (err, "unlock failed");

        return ENOENT;
    }

    if ((err = pthread_mutex_lock(&source_tree->lock)) != 0)
        syserr (err, "unlock failed");
    if ((err = pthread_mutex_unlock(&source_tree->lock)) != 0)
        syserr (err, "unlock failed");

    hmap_insert(target_tree->hm, child_next, source_tree);
    hmap_remove(parent_tree->hm, child_prev);

    if ((err = pthread_mutex_unlock(&target_tree->lock)) != 0)
        syserr (err, "unlock failed");
    if ((err = pthread_mutex_unlock(&parent_tree->lock)) != 0)
        syserr (err, "unlock failed");

    return 0;
}