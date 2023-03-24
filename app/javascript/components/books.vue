<template lang="pug">
.books
  .hoge
    // まずはchoices-jsのUIのことは気にせずselect要素から一覧をfilterするようにしたい
    select
      option(v-for='practice in practices' :value='practice.title' :key='practice.id') {{practice.title}}
  .empty(v-if='books === null')
    .fa-solid.fa-spinner.fa-pulse
    |
    | ロード中
  .books__items(v-else-if='books.length !== 0')
    .row
      book(
        v-for='book in books',
        :key='book.id',
        :book='book',
        :isAdmin='isAdmin',
        :isMentor='isMentor')
  .o-empty-message(v-else)
    .o-empty-message__icon
      i.fa-regular.fa-sad-tear
    p.o-empty-message__text
      | 登録されている本はありません
</template>
<script>
import Book from './book'

export default {
  name: 'Books',
  components: {
    book: Book
  },
  props: {
    isAdmin: { type: Boolean, required: true },
    isMentor: { type: Boolean, required: true },
    practiceId: { type: Number, default: null, required: false }
  },
  data() {
    return {
      books: null,
      filterQuery: {}
    }
  },
  computed: {
    newParams() {
      const params = new URL(location.href).searchParams
      if (this.practiceId) params.set('practice_id', this.practiceId)
      return params
    },
    booksAPI() {
      const params = this.newParams
      return `/api/books.json?${params}`
    },
    practices() {
      // return this.$store.state.practices
      return this.$store.getters.filterQueryById
    }
  },
  created() {
    window.onpopstate = function () {
      location.replace(location.href)
    }
    this.getBooks()
    this.getPractices()
  },
  methods: {
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
    getBooks() {
      fetch(this.booksAPI, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token()
        },
        credentials: 'same-origin',
        redirect: 'manual'
      })
        .then((response) => {
          return response.json()
        })
        .then((json) => {
          this.books = []
          json.books.forEach((r) => {
            this.books.push(r)
          })
        })
        .catch((error) => {
          console.warn(error)
        })
    },
    getPractices() {
      this.$store.dispatch('getAllPractices')
    }
  }
}
</script>
