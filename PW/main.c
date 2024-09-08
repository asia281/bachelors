#include "HashMap.h"
#include "Tree.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <assert.h>

void print_map(HashMap* map) {
    const char* key = NULL;
    void* value = NULL;
    printf("Size=%zd\n", hmap_size(map));
    HashMapIterator it = hmap_iterator(map);
    while (hmap_next(map, &it, &key, &value)) {
        printf("Key=%s Value=%p\n", key, value);
    }
    printf("\n");
}


int main(void)
{
    HashMap* map = hmap_new();
    hmap_insert(map, "a", hmap_new());
    print_map(map);

    HashMap* child = (HashMap*)hmap_get(map, "a");
    hmap_free(child);
    hmap_remove(map, "a");
    print_map(map);

    hmap_free(map);

    Tree *tree = tree_new();
    assert(tree_list(tree, "/a/") == NULL);
     char *list_content = tree_list(tree, "/");
    assert(strcmp(list_content, "") == 0);
    free(list_content);
    assert(tree_create(tree, "/a/") == 0);
    assert(tree_create(tree, "/a/b/") == 0);
     assert(tree_create(tree, "/a/b/") == EEXIST);
     assert(tree_create(tree, "/a/b/c/d/") == ENOENT);
     assert(tree_remove(tree, "/a/") == ENOTEMPTY);
     assert(tree_create(tree, "/b/") == 0);
     assert(tree_create(tree, "/a/c/") == 0);
    assert(tree_create(tree, "/a/cannna/") == 0);
     assert(tree_create(tree, "/a/c/dodo/") == 0);
     assert(tree_move(tree, "/a/c/", "/b/cla/") == 0);
     assert(tree_remove(tree, "/b/cla/dodo/") == 0);
     list_content = tree_list(tree, "/b/");
     assert(strcmp(list_content, "cla") == 0);
     free(list_content);
    tree_free(tree);


    return 0;
}