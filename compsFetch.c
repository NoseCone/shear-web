#include <curl/curl.h>
#include <stdlib.h>
#include <string.h>

#include <urweb.h>

struct response_buffer {
  char *data;
  size_t len;
  size_t cap;
};

static void rb_init(struct response_buffer *rb) {
  rb->cap = 1024;
  rb->len = 0;
  rb->data = malloc(rb->cap);
  if (!rb->data) {
    return;
  }
  rb->data[0] = '\0';
}

static int rb_grow(struct response_buffer *rb, size_t additional) {
  size_t required = rb->len + additional + 1;
  if (required <= rb->cap) {
    return 1;
  }

  size_t new_cap = rb->cap;
  while (new_cap < required) {
    if (new_cap > (SIZE_MAX / 2)) {
      return 0;
    }
    new_cap *= 2;
  }

  char *new_data = realloc(rb->data, new_cap);
  if (!new_data) {
    return 0;
  }

  rb->data = new_data;
  rb->cap = new_cap;
  return 1;
}

static size_t write_callback(void *ptr, size_t size, size_t nmemb, void *userdata) {
  size_t chunk = size * nmemb;
  struct response_buffer *rb = (struct response_buffer *)userdata;

  if (!rb_grow(rb, chunk)) {
    return 0;
  }

  memcpy(rb->data + rb->len, ptr, chunk);
  rb->len += chunk;
  rb->data[rb->len] = '\0';

  return chunk;
}

uw_Basis_string uw_CompsFetch_fetch(uw_context ctx, uw_Basis_string url) {
  CURL *curl = curl_easy_init();
  if (!curl) {
    uw_error(ctx, FATAL, "CompsFetch: failed to initialize libcurl");
  }

  struct response_buffer rb;
  rb_init(&rb);
  if (!rb.data) {
    curl_easy_cleanup(curl);
    uw_error(ctx, FATAL, "CompsFetch: out of memory");
  }

  curl_easy_setopt(curl, CURLOPT_URL, url);
  curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
  curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 10L);
  curl_easy_setopt(curl, CURLOPT_TIMEOUT, 30L);
  curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
  curl_easy_setopt(curl, CURLOPT_WRITEDATA, &rb);
  curl_easy_setopt(curl, CURLOPT_USERAGENT, "shear-web/1.0");

  CURLcode code = curl_easy_perform(curl);
  if (code != CURLE_OK) {
    const char *err = curl_easy_strerror(code);
    free(rb.data);
    curl_easy_cleanup(curl);
    uw_error(ctx, FATAL, "CompsFetch: request failed: %s", err);
  }

  long http_code = 0;
  curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_code);
  curl_easy_cleanup(curl);

  if (http_code < 200 || http_code >= 300) {
    free(rb.data);
    uw_error(ctx, FATAL, "CompsFetch: upstream returned HTTP %ld", http_code);
  }

  char *out = uw_malloc(ctx, rb.len + 1);
  memcpy(out, rb.data, rb.len + 1);
  free(rb.data);

  return out;
}
