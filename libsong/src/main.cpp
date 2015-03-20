#include <bson.h>
#include <mongoc.h>
#include <stdio.h>
#include <map>
#include <string>

using namespace std;


int main(int argc, char *argv[]){

  map<string, string> pLibSong;

  mongoc_client_t *client;
  mongoc_collection_t *collection;
  mongoc_cursor_t *cursor;
  const bson_t *doc;
  bson_t *query;
  char *str;
  char *sname;
  mongoc_init();
  client = mongoc_client_new("mongodb://localhost:27017/");
  collection = mongoc_client_get_collection(client, "local", "song");
  query = bson_new();
  cursor = mongoc_collection_find(
    collection, MONGOC_QUERY_NONE, 0, 0, 0, query, NULL, NULL);
  while(mongoc_cursor_next(cursor, &doc)){
    str = bson_as_json(doc, NULL);
    //TODO
    sname = 
    //printf("%s\n", str);
    map<string, string>::iterator it = pLibSong.begin();
    pLibSong.insert(it, pair<string, string>(str, str));
    //bson_free(str);
  }
  
  bson_destroy(query);
  mongoc_cursor_destroy(cursor);
  mongoc_collection_destroy(collection);
  mongoc_client_destroy(client);

  return 0;
}
