local addonName, pp = ...

--- @class PPItem
--- @field id number The item id
--- @field getName fun():string
--- @field getItem fun():ItemLocationMixin
--- @field getCount fun():number
--- @field getId fun():number
pp.PPItem = {}

--- @param id number
--- @return PPItem
pp.PPItem.new = function(id)
    local self = {}

    --- @type number
    self.id = id

    --- @return string
    function self.getName()
        return C_Item.GetItemNameByID(self.id)
    end

    function self.getItem()
        return Item:CreateFromItemID(self.id)
    end

    --- @return number
    function self.getId()
        return self.id
    end

    --- @return number
    function self.getCount ()
        return C_Item.GetItemCount(self.id, false, false, false, false)
    end

    return self
end
