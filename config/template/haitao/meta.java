package com.netease.haitao.backend.meta.${@sub_package_name};

import java.io.Serializable;
<?rb if @imports ?>
    <?rb for item in @imports ?>
import ${item};
    <?rb end ?>
<?rb end ?>

public class ${@class_name} implements Serializable {

    private static final long serialVersionUID = -1L;

    <?rb for item in @props ?>

    /**
     * ${item[7]}
     */
    private ${item[4]} ${item[1]};
    <?rb end ?>

    <?rb for item in @props ?>
    public ${item[4]} get${item[1][0].upcase}${item[1][1..item[1].length]}(){
        return ${item[1]};
    }

    public void set${item[1][0].upcase}${item[1][1..item[1].length]}(${item[4]} ${item[1]}){
        this.${item[1]} = ${item[1]};
    }

    <?rb end ?>

}