import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const store = new Vuex.Store({
  state: {
    practices: [
      {
        category: '',
        id: null,
        title: 'すべての書籍を表示'
      }
    ],
    filterQuery: {}
  },
  getters: {
    filterQueryById: state => {
      // 初期はid指定なしの状態で、idが渡ってきたらfilterするようにしたい

      return state.practices
    }
  },
  mutations: {
    setPractices(state, practices) {
      practices.forEach(practice => {
        state.practices.push(practice)
      })
    },
    setFilterQuery(state, filterQuery) {
      state.filterQuery = {...filterQuery}
    }
  },
  actions: {
    setInitialFilterQuery({commit}) {
      commit('setFilterQuery', this.filterQuery)
    },
    async getAllPractices({commit}) {
      const practices = await getPracticesAPI()
      commit('setPractices', practices)
    }
  }
})

async function getPracticesAPI() {
  const url = '/api/practices.jspn'
  const res = await fetch(url)
  const data = await res.json()
  const practices = []
  data.forEach(item => {
    practices.push(item)
  })
  return practices
}


export default store
