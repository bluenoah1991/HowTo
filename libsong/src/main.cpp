#include <bson.h>
#include <mongoc.h>
#include <stdio.h>
#include <map>
#include <string>

using namespace std;


int main(int argc, char *argv[]){

  map<string, int> pLibSong;

  mongoc_client_t *client;
  mongoc_collection_t *collection;
  mongoc_collection_t *collection2;
  mongoc_cursor_t *cursor;
  const bson_t *doc;
  bson_t *query;
  char *str;
  char *name;
  mongoc_init();
  bson_error_t error;
  client = mongoc_client_new("mongodb://localhost:27017/");
  collection = mongoc_client_get_collection(client, "local", "song");
  collection2 = mongoc_client_get_collection(client, "local", "song2");
  query = bson_new();
  cursor = mongoc_collection_find(
    collection, MONGOC_QUERY_NONE, 0, 0, 0, query, NULL, NULL);
  bson_iter_t iter;
  map<string, int>::iterator it;
  while(mongoc_cursor_next(cursor, &doc)){
    bson_iter_init(&iter, doc);
    if(bson_iter_find(&iter, "song_name")){
      name = (char*)bson_iter_utf8(&iter, NULL);
      if(name == NULL || strcmp(name, "") == 0){
        continue;
      }
      it = pLibSong.find(name);
      if(it == pLibSong.end()){
        pLibSong.insert(pair<string, int>(name, 0));
        mongoc_collection_insert(
          collection2, MONGOC_INSERT_NONE, doc, NULL, &error);
        printf("insert song %s.\n", name);
      }
    }
  }
  
  bson_destroy(query);
  mongoc_cursor_destroy(cursor);
  mongoc_collection_destroy(collection);
  mongoc_client_destroy(client);

  return 0;
}
