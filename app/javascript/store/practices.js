import Vue from 'vue'
import Vuex from 'vuex'

Vue.use(Vuex)

const store = new Vuex.Store({
  state: {
    practices: [],
    filterQuery: {}
  },
  getters: {
    filterQueryById: state => {
      // 初期はid指定なしの状態で、idが渡ってきたらfilterするようにしたい
      if(state.practices)

      return state.practices
    }
  },
  mutations: {
    setPractices(state, practices) {
      state.practices = practices
    },
    setFilterQuery(state, filterQuery) {
      state.filterQuery = {...filterQuery}
    }
  },
  actions: {
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
  data.forEach((item) => {
    practices.push(item)
  })
  return practices
}


export default store
