const { createApp } = Vue;

createApp({
  data() {
    return {
      devMode: false,
      visible: false,
      showInput: false,
      style: {
        fontSize: 'm'
      },
      language: {},
      categories: [],
      consumables: {},
      currentRoute: 'home',
      activeCraftable: null,
      quantity: 1,
      min: 1,
      max: 10,
      crafttime: 15000,
      testData: [
        {
          Text: "Meat Bfast ",
          SubText: "InvMax = 10",
          Desc: "Recipe: 1x Apple, 1x Water, 1x Sugar, 1x Egg, 1x Flour",
          Items: [
              {
                  name: "meat",
                  count: 1
              },
              {
                  name: "salt",
                  count: 1
              }
          ],
          Reward: [
              {
                  name: "consumable_breakfast",
                  count: 1
              }
          ],
          Job: 0, 
          Location: 0,
          Category: "food"
        }
      ],
      testCategory: [
        {
          ident: 'food', 
          text: 'Craft Food'
        }
      ]
    };
  },
  mounted() {
    // Window Event Listeners
    window.addEventListener("message", this.onMessage);
    window.addEventListener("keydown", this.onKeypress)

    // Debug only
    if (this.devMode) {
      let devData = {
        craftables: this.testData,
        categories: this.testCategory,
        crafttime: 15000,
        style: {
          fontSize: 'm'
        },
        language: {
          InputHeader: 'How many {{msg}} you want to craft',
          InputCraft: 'Craft Item',
          InputCancel: 'Cancel',
          BackButton: 'Back',
          ExitButton: 'Exit',
          CraftHeader: 'Crafting',
          CraftText: 'Press [~e~G~q~] to Craft',
          InvalidAmount: 'Invalid Amount',
          Crafting: 'Crafting...',
          FinishedCrafting: 'You finished crafting',
          PlaceFire: "You're placing a campfire...",
          PutOutFire: 'Putting out the campfire...',
          NotEnough: 'Not enough material for this recipe',
          NotJob: 'You dont have the required job '
        }
      }
      this.setData(devData)
      this.visible = true
    }
  },
  destroyed() {
    // Remove listeners when UI is destroyed to save on memory
    window.removeEventListener("message");
    window.removeEventListener('keydown')
  },
  computed: {
    fontClass() {
      let fontc = {}

      switch(this.style.fontSize) {
        case 's':
          fontc['smallfont'] = true
          break;
        case 'm':
          fontc['mediumfont'] = true
          break;
        case 'l':
          fontc['largefont'] = true
          break;
        default:
          break; 
      }

      return fontc
    },
    InputCraftText() {
      return  this.activeCraftable.Text && this.language.InputHeader ? this.language.InputHeader.replace('{{msg}}', this.activeCraftable.Text) : ''
    }
  },
  methods: {
    onMessage(event) {
      switch(event.data.type) {
        case "bcc-craft-open":
          this.setData(event.data)
          this.visible = true;
          break;
        case "bcc-craft-animate":
          this.animationPlaying()
          break;
        default:
          break;
      }
    },
    onKeypress(event) {
      if (event.key === "I" || event.key === "i") {
        fetch(`https://${GetParentResourceName()}/bcc-openinv`, {
          method: 'POST'
        })
      }

      if (event.key === "Escape" || event.key === "esc") {
        this.currentRoute = 'home'
        this.closeView()
      }
    },
    animationPlaying() {
      this.visible = false
        
      setTimeout(()=>{
        this.visible = true
      }, this.crafttime);
    },
    craftItem() {
      fetch(`https://${GetParentResourceName()}/bcc-craftevent`, {
        method: 'POST',
        body: JSON.stringify({
          craftable: this.activeCraftable,
          quantity: this.quantity
        })
      }).then(resp => resp.json()).then(resp => {
        this.showInput = false
        this.activeCraftable = null
        this.quantity = 1
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
    setData(data) {
      let craftables = data.craftables
      let categories = data.categories
      let crafttime = data.crafttime
      let style = data.style
      let language = data.language



      let consumables = {}

      // Setup object with keys
      categories.forEach(cata => {
        consumables[cata.ident] = []
      });

      // Fill object created above
      craftables.forEach(element => {
        consumables[element.Category].push(element)
      });


      this.language = language
      this.consumables = consumables
      this.categories = categories
      this.crafttime = crafttime
      this.style = style
    }
  },
}).mount("#app");
