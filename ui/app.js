const { createApp } = Vue;

createApp({
  data() {
    return {
      visible: false,
      showInput: false,
      categories: [],
      consumables: {},
      currentRoute: 'home',
      activeCraftable: null,
      quantity: 1,
      min: 1,
      max: 10,
      crafttime: 15000,
      testData: [{"Type":1,"SubText":"InvMax = 10","Items":[{"name":"consumable_game","count":1},{"name":"salt","count":1}],"Text":"Seasoned Small Game ","Desc":"Recipe: 1 x SGM, 1 x Salt","Prop":0,"Job":0,"Reward":[{"name":"cookedsmallgame","count":2}],"Location":0},{"Type":1,"SubText":"InvMax = 10","Items":[{"name":"apple","count":1},{"name":"water","count":1},{"name":"sugar","count":1},{"name":"flour","count":1},{"name":"eggs","count":1}],"Text":"Apple Pie ","Desc":"Recipe: 1x Apple, 1x Water, 1x Sugar, 1x Egg, 1x Flour","Prop":0,"Job":0,"Reward":[{"name":"consumable_applepie","count":1}],"Location":0},{"Type":1,"SubText":"InvMax = 10","Items":[{"name":"meat","count":1}],"Text":"Steak ","Desc":"Recipe: 1x Meat","Prop":0,"Job":0,"Reward":[{"name":"steak","count":1}],"Location":0},{"Type":1,"SubText":"InvMax = 5","Items":[{"name":"Pork","count":1},{"name":"eggs","count":2}],"Text":"Breakfast ","Desc":"Recipe: 1x Pork, 2x Eggs","Prop":0,"Job":0,"Reward":[{"name":"consumable_breakfast","count":1}],"Location":0},{"Type":1,"SubText":"InvMax = 10","Items":[{"name":"blueberry","count":6},{"name":"water","count":1},{"name":"sugar","count":1},{"name":"eggs","count":1},{"name":"flour","count":1}],"Text":"Blueberry Pie ","Desc":"Recipe: 6x BlueBerry, 1 x Water, 1x Sugar, 1x Egg, 1x Flour","Prop":0,"Job":0,"Reward":[{"name":"consumable_blueberrypie","count":1}],"Location":0},{"Type":1,"SubText":"InvMax = 10 ","Items":[{"name":"Pork","count":1},{"name":"salt","count":1}],"Text":"Seasoned Porkchop","Desc":"Recipe: 1x Pork, 1x Salt","Prop":0,"Job":0,"Reward":[{"name":"saltedcookedpork","count":1}],"Location":0},{"Type":1,"SubText":"InvMax = 10","Items":[{"name":"BigGameMeat","count":1},{"name":"salt","count":1}],"Text":"Seasoned Big Game","Desc":"Recipe 1x Big Game Meat, 1x Salt","Prop":0,"Job":0,"Reward":[{"name":"SaltedCookedBigGameMeat","count":1}],"Location":0},{"Type":1,"SubText":"InvMax = 10","Items":[{"name":"BigGameMeat","count":1}],"Text":"Plain Big Game Meat","Desc":"Recipe: 1x Big Game Meat","Prop":0,"Job":0,"Reward":[{"name":"CookedBigGameMeat","count":1}],"Location":0},{"Type":1,"SubText":"InvMax = 10","Items":[{"name":"Pork","count":1}],"Text":"PorkChop ","Desc":"Recipe: 1x Pork","Prop":0,"Job":0,"Reward":[{"name":"cookedpork","count":1}],"Location":0},{"Type":0,"SubText":"InvMax = 5","Items":[{"name":"iron","count":10},{"name":"wood","count":2}],"Text":"PickAxe ","Desc":"Recipe: 10x Iron, 2x Wood","Prop":0,"Job":0,"Reward":[{"name":"pickaxe","count":1}],"Location":0},{"Type":0,"SubText":"InvMax = 5","Items":[{"name":"iron","count":10},{"name":"wood","count":2}],"Text":"Axe ","Desc":"Recipe: 10x Iron, 2x Wood","Prop":0,"Job":0,"Reward":[{"name":"Axe","count":1}],"Location":0},{"Type":0,"SubText":"InvMax = 5","Items":[{"name":"rock","count":10},{"name":"wood","count":5},{"name":"coal","count":4}],"Text":"Campfire ","Desc":"Recipe: 10x Rock, 5x Wood, 4x Coal","Prop":0,"Job":0,"Reward":[{"name":"campfire","count":1}],"Location":0},{"Type":1,"SubText":"InvMax = 10","Items":[{"name":"rawbirdmeat","count":1}],"Text":"Plain Cooked Bird ","Desc":"Recipe: 1x Raw Bird Meat","Prop":0,"Job":0,"Reward":[{"name":"cookedbird","count":1}],"Location":0},{"Type":0,"SubText":"InvMax = 15","Items":[{"name":"gold","count":1}],"Text":"Refined Gold Ore ","Desc":"Recipe: 1x Gold Ore","Prop":0,"Job":0,"Reward":[{"name":"golden_nugget","count":1}],"Location":0},{"Type":1,"SubText":"InvMax = 10 ","Items":[{"name":"consumable_game","count":1}],"Text":"Plain Small Game ","Desc":"Recipe: 1x Small Game Meat","Prop":0,"Job":0,"Reward":[{"name":"plainsmallgame","count":1}],"Location":0},{"Type":0,"SubText":"InvMax = 10","Items":[{"name":"fibers","count":10}],"Text":"Rope ","Desc":"Recipe: 10x Fibers","Prop":0,"Job":0,"Reward":[{"name":"rope","count":1}],"Location":0},{"Type":0,"SubText":"InvMax = 10","Items":[{"name":"wool","count":10}],"Text":"Cloth ","Desc":"Recipe: 10x Wool","Prop":0,"Job":0,"Reward":[{"name":"cloth","count":1}],"Location":0},{"Type":0,"SubText":"InvMax = 5 ","Items":[{"name":"cloth","count":4},{"name":"rope","count":3},{"name":"wood","count":2}],"Text":"Tent ","Desc":"Recipe: 4x Cloth, 3x Rope, 2x Wood","Prop":0,"Job":0,"Reward":[{"name":"tent","count":1}],"Location":0},{"Type":0,"SubText":"InvMax = 5","Items":[{"name":"pelt","count":4},{"name":"cloth","count":1},{"name":"wood","count":2}],"Text":"Bedroll ","Desc":"Recipe: 4x Pelt, 1x Cloth, 2x Wood","Prop":0,"Job":0,"Reward":[{"name":"bedroll","count":1}],"Location":0},{"Type":0,"SubText":"InvMax = 20","Items":[{"name":"Indian_Tobbaco","count":1},{"name":"fibers","count":1}],"Text":"Cigar","Desc":"Recipe: 1x Indian Tobacco, 1x Fiber","Prop":0,"Job":0,"Reward":[{"name":"cigar","count":1}],"Location":0},{"Type":0,"SubText":"InvMax = 20","Items":[{"name":"Indian_Tobbaco","count":1},{"name":"fibers","count":1}],"Text":"Cigarette ","Desc":"Recipe: 1x Indian Tobacco, 1x Fiber","Prop":0,"Job":0,"Reward":[{"name":"cigarette","count":1}],"Location":0},{"Type":1,"SubText":"InvMax = 10","Items":[{"name":"meat","count":2},{"name":"eggs","count":2},{"name":"potato","count":2}],"Text":"Steak n' Eggs ","Desc":"Recipe: 2x Meat, 2x Eggs, 2x potatoes","Prop":0,"Job":0,"Reward":[{"name":"steakeggs","count":1}],"Location":0},{"Type":1,"SubText":"InvMax = 10","Items":[{"name":"carrot","count":2},{"name":"corn","count":2},{"name":"potato","count":2},{"name":"water","count":1},{"name":"salt","count":2}],"Text":"Veggie Stew ","Desc":"Recipe: 2x Carrots, 2x Corn, 2x Potatoes, 1xwater, 2x Salt","Prop":0,"Job":0,"Reward":[{"name":"vegstew","count":1}],"Location":0},{"Type":1,"SubText":"InvMax = 10","Items":[{"name":"Pork","count":1},{"name":"apple","count":2}],"Text":"Porkchops and Applesauce ","Desc":"Recipe: 1x Pork, 2x Apples","Prop":0,"Job":0,"Reward":[{"name":"porknapples","count":1}],"Location":0},{"Type":1,"SubText":"InvMax = 10","Items":[{"name":"rawbirdmeat","count":2},{"name":"carrot","count":2},{"name":"corn","count":1},{"name":"water","count":2},{"name":"salt","count":2}],"Text":"Bird Stew ","Desc":"Recipe: 2x Raw Bird, 2x Carrots, 1x Corn, 2x Water, 2x Salt","Prop":0,"Job":0,"Reward":[{"name":"birdstew","count":1}],"Location":0}]
    };
  },
  mounted() {
    window.addEventListener("message", this.onMessage);
    // Debug only
    // this.setData(this.testData)
  },
  destroyed() {
    window.removeEventListener("message");
  },
  computed: {
  },
  methods: {
    onMessage(event) {
      console.log("EVENT RECEIVED:", event.data.type)
      switch(event.data.type) {
        case "bcc-craft-open":
          this.setData(event.data.craftables, event.data.categories, event.data.crafttime)
          this.visible = true;
          break;
        default:
          break;
      }
    },
    craftItem() {
      fetch(`https://${GetParentResourceName()}/bcc-craftevent`, {
        method: 'POST',
        body: JSON.stringify({
          craftable: this.activeCraftable,
          quantity: this.quantity
        })
      }).then((response) => {
        if (response.ok) {
          return response.json();
        }
        return Promise.reject(response);
      }).then(() => {
        this.showInput = false
        this.activeCraftable = null
        this.quantity = 1

        this.visible = false
        setTimeout(()=>{
          this.visible = true
        }, this.crafttime);
      }).catch(function (error) {
        console.warn(error);
      })
    },
    handleItemClick(data) {
      this.activeCraftable = data
      this.showInput = true
    },
    formatQuantity() {
      if (this.quantity <= this.min - 1) {
          this.quantity = this.min
      }

      if (this.quantity > this.max) {
          this.quantity = this.max
      }
    },
    increase() {
        let value = this.quantity
        value = isNaN(value) ? this.min : value;

        if (value >= this.max) {
            value = this.max - 1
        }

        value++;
        this.quantity = value
    },
    decrease() {
        let value = this.quantity
        value = isNaN(value) ? this.min : value;
        value < this.min ? value = this.min : '';
        value--;
        value < this.min ? value = this.min : '';
        this.quantity = value
    },
    closeView() {
      this.visible = false;
      fetch(`https://${GetParentResourceName()}/bcc-craft-close`, {
        method: 'POST'
      })
    },
    setData(data, cat, crafttime) {
      let consumables = {}

      cat.forEach(cata => {
        consumables[cata.ident] = []
      });

      data.forEach(element => {
        consumables[element.Category].push(element)
      });

      this.consumables = consumables
      this.categories = cat
      this.crafttime = crafttime
    }
  },
}).mount("#app");
