# -*- encoding : utf-8 -*-
module CodeGensHelper

    class Coding

        def initialize(project_name)
            @config = JSON.parse(File.read("#{Rails.root}/config/core/#{project_name}_config.json"))
            @template_path = "#{Rails.root}/config/template/#{project_name}"
        end

        def parse_db(table_name)
            begin
                db = Mysql.init
                db.options(Mysql::SET_CHARSET_NAME, 'utf8')
                db = Mysql.real_connect(@config['db_host'], @config['db_user'], @config['db_password'], @config['db_name'], @config['db_port'])
                results = db.query("desc #{table_name};")
                rlt = []
                results.each do |row|
                    unless @config['ignore_columns'].index(row[0].upcase)
                        java_type = to_java_type(row[1])
                        rlt <<([]<< row[0] << to_prop_name(row[0]) << row[1] << java_type << to_simple_java_type(java_type)<<build_db_method(java_type)<<to_jdbc_type(row[1]) << row[6])
                    end
                end
                rlt
            rescue Mysql::Error => e
                puts "Error code: #{e.errno}"
                puts "Error message: #{e.error}"
                puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
            ensure
                db.close if db
            end
        end

        # 表名->Java类名
        def to_class_name(table_name)
            words = []
            table_name.downcase.split('_').each { |word| words << word.capitalize }
            words.join
        end

        # 数据库字段名称->Java对象属性名称
        def to_prop_name(column_name)
            words = []
            column_name.downcase.split('_').each { |word| words << word.capitalize }
            prop_name = words.join
            prop_name[0].downcase << prop_name[1..prop_name.length]
        end

        def to_jdbc_type(column_type)
            if column_type =~ /int/
                return 'INTEGER'
            elsif column_type =~ /^varchar/
                return 'VARCHAR'
            elsif column_type =~ /timestamp/
                return 'TIMESTAMP'
            elsif column_type =~ /decimal/
                return 'DECIMAL'
            else
                throw Exception
            end
        end

        # 数据库字段类型->Java对象属性类型
        def to_java_type(column_type)
            if column_type =~ /int/
                return 'java.lang.Integer'
            elsif column_type =~ /varchar/
                return 'java.lang.String'
            elsif column_type =~ /timestamp/
                return 'java.util.Date'
            elsif column_type =~ /decimal/
                return 'java.math.BigDecimal'
            else
                throw Exception
            end
        end

        def to_simple_java_type(java_type)
            java_type.split('.').last
        end

        # 过滤imports的类.某些类不想要import声明
        def filter_imports(rlt)
            imports = []
            rlt.each do |line|
                unless line[3].start_with?('java.lang')
                    imports << line[3]
                end
            end
            imports.uniq
        end

        def build_base_column_list(props)
            rlt = []
            col = ''
            props.length.times do |i|
                col << props[i][0].upcase << (', ')
                if (i+1)%7 == 0 or i == props.length-1
                    rlt << col
                    col=''
                end
            end
            rlt[-1] = rlt[-1].rstrip.sub(/,$/, '')
            rlt
        end

        def build_db_method(java_type)
            @config['db_method_mapping'][java_type]
        end

        def generate(engine, context)
            files = Dir.entries(@template_path) - %w(. ..)
            files.each do |file|
                output = engine.render(@template_path + "/#{file}", context)
                File.open(out_file_name(file,context), 'w') { |file| file.write(output.force_encoding('UTF-8')) }
            end
        end

        def out_file_name(file, context)
            @out_path + "/#{context[:class_name]}" + (file == 'meta.java' ? '.java' : file[0].upcase+file[1..file.length])
        end

        def clear
            Dir.foreach(@template_path) { |file| File.delete(@template_path + '/' + file) if file =~/.cache/ }
        end

        def clear_before(path)
            FileUtils.remove_dir(path,true)
        end

    end

    class HaitaoCodeGen < Coding

        # 数据库字段类型->Java对象属性类型
        def to_java_type(column_type)
            @config['type_mapping'][column_type.upcase]
        end

        def to_jdbc_type(column_type)
            @config['jdbc_type_mapping'][column_type.upcase]
        end

# DB 插入语句
        def build_insert_sql(table_name, props)
            sql = "Insert into #{table_name} ("
            props.each do |item|
                sql << item[0] << ','
            end
            sql.sub(/,$/, ')')<< ' values '
        end

# DB 更新语句
        def build_update_sql(table_name, props)
            column_update = ''
            props.each do |item|
                if item[1].upcase !='ID'
                    column_update << item[1] << ' = ?, '
                end
            end
            "UPDATE #{table_name} SET " << column_update.sub(/, $/, ' ') << 'WHERE ID = ?'
        end


# 生成 update语句参数
        def build_update_params(props)
            params = []
            props.each do |item|
                params << ('get'<<item[1][0].upcase<<item[1][1..item[1].length])
            end
            params.drop(1) << 'getId'
        end


# 解析均衡字段,在DDB数据库中需要。
        def parse_policy_column(table_name)
            begin
                db = Mysql.init
                db.options(Mysql::SET_CHARSET_NAME, 'utf8')
                db = Mysql.real_connect(@config['db_host'], @config['db_user'], @config['db_password'], @config['db_name'], @config['db_port'])
                results = db.query("show create table  #{table_name} ;")
                results.fetch_row.each do |row|
                    return row.slice(/(?<=BF=)\w*/) unless table_name.eql?(row)
                end
            rescue Mysql::Error => e
                puts "Error code: #{e.errno}"
                puts "Error message: #{e.error}"
                puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
            ensure
                db.close if db
            end
        end

        def generate_code(table_name, sub_pack_name)
            engine = Tenjin::Engine.new
            @out_path = "#{Rails.root}/config/out/#{table_name}"
            clear_before(@out_path)
            FileUtils.mkdir_p(@out_path)

            rlt = parse_db(table_name)
            policy_column = parse_policy_column(table_name)
            policy_field = to_prop_name(policy_column)

            imports = filter_imports(rlt)
            class_name = to_class_name (table_name)
            update_sql = build_update_sql(table_name, rlt)
            update_params = build_update_params(rlt)
            insert_sql = build_insert_sql(table_name, rlt)

            column_list = build_base_column_list(rlt)
            up_props = rlt.clone.drop(1).keep_if { |a| !policy_column.eql?(a[0]) and !'db_update_time'.eql?(a[0]) and !'db_create_time'.eql? (a[0]) }


            context = {:sub_package_name => sub_pack_name,
                       :imports => imports,
                       :class_name => class_name,
                       :props => rlt,
                       :up_props => up_props,
                       :table_name => table_name,
                       :update_sql => update_sql,
                       :update_params => update_params,
                       :insert_sql => insert_sql,
                       :column_list => column_list,
                       :policy_column => policy_column,
                       :policy_field => policy_field}

            generate(engine, context)
            clear
        end
    end


    class SupplierCodeGen < Coding

        def generate_code(table_name, sub_pack_name)
            engine = Tenjin::Engine.new
            @out_path = "#{Rails.root}/config/out/#{table_name}"
            clear_before(@out_path)
            FileUtils.mkdir_p(@out_path)

            rlt = parse_db(table_name)
            imports = filter_imports(rlt)
            @class_name = to_class_name (table_name)
            column_list = build_base_column_list(rlt)

            context = {
                :imports => imports,
                :class_name => @class_name,
                :props => rlt,
                :table_name => table_name,
                :column_list => column_list}

            generate(engine, context)
            clear
            puts 'Generate Code Done!'
        end
    end

end
